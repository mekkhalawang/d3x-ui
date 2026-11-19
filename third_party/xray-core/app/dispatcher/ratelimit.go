package dispatcher

import (
	"encoding/json"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"github.com/xtls/xray-core/common"
	"github.com/xtls/xray-core/common/buf"
)

// Per-user bandwidth limits live in a side file instead of the protobuf config
// so this patch stays small when rebasing onto a new xray-core. The panel writes
// the file and points XRAY_RATELIMIT_FILE at it.
//
//	{"users":{"alice@example.com":{"up":125000,"down":1000000}}}
//
// Values are bytes per second; 0 (or a missing side) means unlimited.

type rateLimitEntry struct {
	Up   int64 `json:"up"`
	Down int64 `json:"down"`
}

type rateLimitFile struct {
	Users map[string]rateLimitEntry `json:"users"`
}

type tokenBucket struct {
	label  string
	bytes  int64
	start  time.Time
	waits  int64
	mu     sync.Mutex
	rate   float64
	burst  float64
	tokens float64
	last   time.Time
}

func newTokenBucket(label string, bytesPerSecond int64) *tokenBucket {
	if os.Getenv("XRAY_RATELIMIT_DEBUG") != "" {
		fmt.Fprintf(os.Stderr, "D3XDEBUG bucket %s rate=%d\n", label, bytesPerSecond)
	}
	rate := float64(bytesPerSecond)
	burst := rate / 4
	if burst < 64*1024 {
		burst = 64 * 1024
	}
	return &tokenBucket{label: label, rate: rate, burst: burst, tokens: burst, last: time.Now(), start: time.Now()}
}

// wait blocks until n bytes fit in the bucket. Concurrent connections of the
// same user share one bucket, so a client cannot multiply its limit by opening
// more streams.
func (b *tokenBucket) wait(n int) {
	if n <= 0 {
		return
	}
	for {
		b.mu.Lock()
		now := time.Now()
		b.tokens += now.Sub(b.last).Seconds() * b.rate
		b.last = now
		if b.tokens > b.burst {
			b.tokens = b.burst
		}
		if b.tokens >= float64(n) {
			b.tokens -= float64(n)
			b.bytes += int64(n)
			b.waits++
			if os.Getenv("XRAY_RATELIMIT_DEBUG") != "" && b.waits%2000 == 0 {
				elapsed := time.Since(b.start).Seconds()
				fmt.Fprintf(os.Stderr, "D3XDEBUG %s waits=%d bytes=%d elapsed=%.1fs achieved=%.0f B/s\n", b.label, b.waits, b.bytes, elapsed, float64(b.bytes)/elapsed)
			}
			b.mu.Unlock()
			return
		}
		deficit := float64(n) - b.tokens
		b.tokens = 0
		b.bytes += int64(n)
		b.waits++
		b.mu.Unlock()
		if os.Getenv("XRAY_RATELIMIT_DEBUG") != "" && b.waits%1000 == 0 {
			fmt.Fprintf(os.Stderr, "D3XDEBUG waits=%d n=%d rate=%.0f\n", b.waits, n, b.rate)
		}
		time.Sleep(time.Duration(deficit / b.rate * float64(time.Second)))
	}
}

type userRateLimit struct {
	up   *tokenBucket
	down *tokenBucket
}

var (
	rateLimitFileMu     sync.Mutex
	rateLimitFilePath   string
	rateLimitUsers      atomic.Value // map[string]*userRateLimit
	rateLimitLoadedAt   atomic.Int64
	rateLimitFileStamp  atomic.Int64
	rateLimitReloadEach = 2 * time.Second
)

func init() {
	if p := os.Getenv("XRAY_RATELIMIT_FILE"); p != "" {
		SetRateLimitFile(p)
	}
}

// SetRateLimitFile enables per-user shaping from path. An empty path disables it.
func SetRateLimitFile(path string) {
	rateLimitFileMu.Lock()
	rateLimitFilePath = path
	rateLimitFileMu.Unlock()
	rateLimitUsers.Store(map[string]*userRateLimit(nil))
	rateLimitLoadedAt.Store(0)
}

func currentRateLimitFile() string {
	rateLimitFileMu.Lock()
	defer rateLimitFileMu.Unlock()
	return rateLimitFilePath
}

// lookupRateLimit returns the buckets for email, reloading the side file when its
// mtime changes. It is called once per connection, not per packet.
func lookupRateLimit(email string) *userRateLimit {
	path := currentRateLimitFile()
	if path == "" || email == "" {
		return nil
	}
	now := time.Now().UnixNano()
	if now-rateLimitLoadedAt.Load() >= int64(rateLimitReloadEach) {
		rateLimitLoadedAt.Store(now)
		if info, err := os.Stat(path); err == nil {
			stamp := info.ModTime().UnixNano() ^ info.Size()
			if stamp != rateLimitFileStamp.Load() {
				rateLimitFileStamp.Store(stamp)
				loadRateLimitFile(path)
			}
		}
	}
	if users, ok := rateLimitUsers.Load().(map[string]*userRateLimit); ok {
		return users[email]
	}
	return nil
}

func loadRateLimitFile(path string) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return
	}
	var parsed rateLimitFile
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return
	}
	users := make(map[string]*userRateLimit, len(parsed.Users))
	for email, entry := range parsed.Users {
		limit := &userRateLimit{}
		if entry.Up > 0 {
			limit.up = newTokenBucket("up", entry.Up)
		}
		if entry.Down > 0 {
			limit.down = newTokenBucket("down", entry.Down)
		}
		if limit.up != nil || limit.down != nil {
			users[email] = limit
		}
	}
	rateLimitUsers.Store(users)
}

// rateLimitWriter shapes one direction of a user's link.
type rateLimitWriter struct {
	writer buf.Writer
	bucket *tokenBucket
}

func newRateLimitWriter(writer buf.Writer, bucket *tokenBucket) *rateLimitWriter {
	return &rateLimitWriter{writer: writer, bucket: bucket}
}

func (w *rateLimitWriter) WriteMultiBuffer(mb buf.MultiBuffer) error {
	for i, b := range mb {
		w.bucket.wait(int(b.Len()))
		if err := w.writer.WriteMultiBuffer(buf.MultiBuffer{b}); err != nil {
			buf.ReleaseMulti(mb[i+1:])
			return err
		}
	}
	return nil
}

// rateLimitReader shapes the download direction of a DispatchLink link.
type rateLimitReader struct {
	reader buf.Reader
	bucket *tokenBucket
}

func newRateLimitReader(reader buf.Reader, bucket *tokenBucket) *rateLimitReader {
	return &rateLimitReader{reader: reader, bucket: bucket}
}

func (r *rateLimitReader) ReadMultiBuffer() (buf.MultiBuffer, error) {
	mb, err := r.reader.ReadMultiBuffer()
	if mb != nil {
		r.bucket.wait(int(mb.Len()))
	}
	return mb, err
}

func (r *rateLimitReader) Interrupt() {
	common.Interrupt(r.reader)
}

func (w *rateLimitWriter) Interrupt() {
	common.Interrupt(w.writer)
}

func (w *rateLimitWriter) Close() error {
	return common.Close(w.writer)
}
