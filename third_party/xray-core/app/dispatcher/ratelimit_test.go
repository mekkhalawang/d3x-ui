package dispatcher

import (
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"
)

func writeLimits(t *testing.T, body string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "ratelimit.json")
	if err := os.WriteFile(path, []byte(body), 0o600); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestRateLimitFileLoadsPerUser(t *testing.T) {
	path := writeLimits(t, `{"users":{"a@x":{"up":125000,"down":1000000},"b@x":{"down":500000}}}`)
	SetRateLimitFile(path)
	defer SetRateLimitFile("")

	users := map[string]*userRateLimit{}
	for _, email := range []string{"a@x", "b@x", "c@x"} {
		users[email] = lookupRateLimit(email)
	}
	if users["a@x"] == nil || users["b@x"] == nil {
		t.Fatal("configured users missing")
	}
	if users["c@x"] != nil {
		t.Fatal("unlimited user got a bucket")
	}
	if users["a@x"].up == nil || users["a@x"].down == nil {
		t.Fatal("a@x should shape both directions")
	}
	if users["b@x"].up != nil {
		t.Fatal("b@x has no upload limit")
	}
}

func TestRateLimitFileReloadsOnChange(t *testing.T) {
	path := writeLimits(t, `{"users":{"a@x":{"down":1000}}}`)
	SetRateLimitFile(path)
	defer SetRateLimitFile("")

	if lookupRateLimit("a@x") == nil {
		t.Fatal("initial load missed")
	}
	time.Sleep(5 * time.Millisecond)
	if err := os.WriteFile(path, []byte(`{"users":{}}`), 0o600); err != nil {
		t.Fatal(err)
	}
	// The reload interval is 2s; shrink it for the test.
	old := rateLimitReloadEach
	rateLimitReloadEach = 0
	defer func() { rateLimitReloadEach = old }()
	if lookupRateLimit("a@x") != nil {
		t.Fatal("removed limit survived reload")
	}
}

func TestTokenBucketSpreadsLargeWrites(t *testing.T) {
	b := newTokenBucket("down", 100000) // 100 kB/s
	start := time.Now()
	b.wait(100000) // burst is 64 KiB, so ~360ms must be paid
	elapsed := time.Since(start)
	if elapsed < 250*time.Millisecond {
		t.Fatalf("bucket drained too fast: %v", elapsed)
	}
	if elapsed > 2*time.Second {
		t.Fatalf("bucket too slow: %v", elapsed)
	}
}

// TestTokenBucketSustainedRate keeps asking for small chunks after the burst is
// exhausted. The old bucket zeroed the token counter before sleeping only for
// the deficit, so it woke up with (n - old_tokens) tokens — never enough for n —
// and oscillated forever. That showed up as 0 B/s once the burst ran out.
func TestTokenBucketSustainedRate(t *testing.T) {
	b := newTokenBucket("down", 100000) // 100 kB/s, burst 64 KiB
	start := time.Now()
	for i := 0; i < 20; i++ {
		b.wait(10000)
	}
	elapsed := time.Since(start)
	// 200 kB at 100 kB/s ≈ 2s, minus the initial burst credit (~0.65s) → 1.35s.
	if elapsed < 500*time.Millisecond {
		t.Fatalf("200kB at 100kB/s finished too fast: %v", elapsed)
	}
	if elapsed > 5*time.Second {
		t.Fatalf("200kB at 100kB/s took too long (stalling?): %v", elapsed)
	}
}

// TestTokenBucketLargerThanBurst covers a single write bigger than the bucket
// capacity (e.g. the flush in shaperWriter.Close or a big upstream read). The
// token cap must not be able to strand a request below n forever.
func TestTokenBucketLargerThanBurst(t *testing.T) {
	b := newTokenBucket("down", 200000) // burst = max(50 kB, 64 KiB) = 64 KiB
	start := time.Now()
	b.wait(150000) // 150 kB > burst
	elapsed := time.Since(start)
	if elapsed > 3*time.Second {
		t.Fatalf("wait larger than burst took too long: %v", elapsed)
	}
}

// TestTokenBucketConcurrentSharesLimit opens 4 streams on one bucket. Total
// throughput must stay near the configured rate — that is the acceptance
// criterion for "4 concurrent connections still capped in aggregate".
func TestTokenBucketConcurrentSharesLimit(t *testing.T) {
	b := newTokenBucket("down", 200000) // 200 kB/s shared
	start := time.Now()
	var wg sync.WaitGroup
	for i := 0; i < 4; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < 10; j++ {
				b.wait(20000) // 200 kB total per stream, 800 kB combined
			}
		}()
	}
	wg.Wait()
	elapsed := time.Since(start)
	// 800 kB at 200 kB/s = 4s, minus burst credit 64 KiB ≈ 0.3s.
	if elapsed < 2500*time.Millisecond {
		t.Fatalf("4 streams leaked past the shared limit: %v", elapsed)
	}
	if elapsed > 10*time.Second {
		t.Fatalf("4 streams starved: %v", elapsed)
	}
}
