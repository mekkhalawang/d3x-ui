package service

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/mekkhalawang/d3x-ui/v3/internal/database"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database/dbtest"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database/model"
	"github.com/mekkhalawang/d3x-ui/v3/internal/xray"
)

func TestSyncRateLimitFileWritesEnabledClientsOnly(t *testing.T) {
	bin := t.TempDir()
	t.Setenv("XUI_BIN_FOLDER", bin)
	// Shaping is gated off by default; the test asks for it explicitly.
	t.Setenv("XUI_RATELIMIT_ENABLE", "1")
	dbtest.InitDB(t, filepath.Join(t.TempDir(), "d3x-ui.db"))

	inbound := &model.Inbound{
		Remark:   "shape",
		Protocol: model.VLESS,
		Port:     443,
		Enable:   true,
		Settings: `{"clients":[
			{"email":"fast@x","id":"11111111-1111-1111-1111-111111111111","enable":true},
			{"email":"slow@x","id":"22222222-2222-2222-2222-222222222222","enable":true,"speedLimitUp":10000,"speedLimitDown":50000},
			{"email":"off@x","id":"33333333-3333-3333-3333-333333333333","enable":false,"speedLimitUp":10000}
		]}`,
	}
	if err := database.GetDB().Create(inbound).Error; err != nil {
		t.Fatal(err)
	}

	syncRateLimitFile()

	raw, err := os.ReadFile(xray.GetRateLimitPath())
	if err != nil {
		t.Fatalf("ratelimit.json not written: %v", err)
	}
	var got rateLimitPayload
	if err := json.Unmarshal(raw, &got); err != nil {
		t.Fatal(err)
	}
	if len(got.Users) != 1 {
		t.Fatalf("users = %v, want only slow@x", got.Users)
	}
	slow, ok := got.Users["slow@x"]
	if !ok {
		t.Fatalf("slow@x missing: %v", got.Users)
	}
	// kbps -> bytes/s
	if slow.Up != 10000*125 || slow.Down != 50000*125 {
		t.Fatalf("slow@x = %+v, want up=%d down=%d", slow, 10000*125, 50000*125)
	}
}

// TestSyncRateLimitFileStaysEmptyWithoutEnv asserts the safety valve: without
// XUI_RATELIMIT_ENABLE the side file is written but empty, so a stale limit can
// never throttle a box that did not opt in.
func TestSyncRateLimitFileStaysEmptyWithoutEnv(t *testing.T) {
	bin := t.TempDir()
	t.Setenv("XUI_BIN_FOLDER", bin)
	t.Setenv("XUI_RATELIMIT_ENABLE", "")
	dbtest.InitDB(t, filepath.Join(t.TempDir(), "d3x-ui.db"))

	inbound := &model.Inbound{
		Remark:   "shape",
		Protocol: model.VLESS,
		Port:     443,
		Enable:   true,
		Settings: `{"clients":[
			{"email":"slow@x","id":"22222222-2222-2222-2222-222222222222","enable":true,"speedLimitDown":50000}
		]}`,
	}
	if err := database.GetDB().Create(inbound).Error; err != nil {
		t.Fatal(err)
	}

	syncRateLimitFile()

	raw, err := os.ReadFile(xray.GetRateLimitPath())
	if err != nil {
		t.Fatalf("ratelimit.json not written: %v", err)
	}
	var got rateLimitPayload
	if err := json.Unmarshal(raw, &got); err != nil {
		t.Fatal(err)
	}
	if len(got.Users) != 0 {
		t.Fatalf("users = %v, want empty without XUI_RATELIMIT_ENABLE", got.Users)
	}
}
