package dispatcher

import (
	"os"
	"path/filepath"
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
	b := newTokenBucket(100000) // 100 kB/s
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
