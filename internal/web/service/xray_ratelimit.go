package service

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"

	"github.com/mekkhalawang/d3x-ui/v3/internal/database"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database/model"
	"github.com/mekkhalawang/d3x-ui/v3/internal/logger"
	"github.com/mekkhalawang/d3x-ui/v3/internal/xray"
)

// rateLimitUser is one entry of the side file the patched core reads. Rates are
// bytes per second; 0 means unlimited in that direction.
type rateLimitUser struct {
	Up   int64 `json:"up"`
	Down int64 `json:"down"`
}

type rateLimitPayload struct {
	Users map[string]rateLimitUser `json:"users"`
}

// kbpsToBytes converts the panel's kbps setting to bytes per second.
func kbpsToBytes(kbps int) int64 {
	if kbps <= 0 {
		return 0
	}
	return int64(kbps) * 125
}

// rateLimitEnabled reports whether shaping may be handed to the patched core.
// It is off by default: the core side is still being validated, and a stale
// limit file must never throttle traffic on a box that did not ask for it.
func rateLimitEnabled() bool {
	switch strings.ToLower(strings.TrimSpace(os.Getenv("XUI_RATELIMIT_ENABLE"))) {
	case "1", "true", "yes", "on":
		return true
	}
	return false
}

// syncRateLimitFile rewrites XRAY_RATELIMIT_FILE for the current inbound set.
// The core watches the file's mtime, so this runs beside every config build and
// a limit change takes effect on the next connection without a restart.
func syncRateLimitFile() {
	payload := rateLimitPayload{Users: map[string]rateLimitUser{}}
	if !rateLimitEnabled() {
		writeRateLimitFile(payload)
		return
	}

	var inbounds []*model.Inbound
	if err := database.GetDB().Where("enable = ?", true).Find(&inbounds).Error; err != nil {
		logger.Warning("rate limit: read inbounds failed:", err)
		return
	}
	for _, inbound := range inbounds {
		// Node-owned inbounds run on the node's own panel, which writes its file.
		if inbound.NodeID != nil {
			continue
		}
		clients, err := ParseInboundSettingsClients(inbound.Settings)
		if err != nil {
			continue
		}
		for _, client := range clients {
			if !client.Enable || (client.SpeedLimitUp <= 0 && client.SpeedLimitDown <= 0) {
				continue
			}
			email := strings.TrimSpace(client.Email)
			if email == "" {
				continue
			}
			payload.Users[email] = rateLimitUser{
				Up:   kbpsToBytes(client.SpeedLimitUp),
				Down: kbpsToBytes(client.SpeedLimitDown),
			}
		}
	}

	writeRateLimitFile(payload)
}

// writeRateLimitFile puts the table on disk atomically; the file holds client
// emails, so it stays 0600.
func writeRateLimitFile(payload rateLimitPayload) {
	raw, err := json.Marshal(payload)
	if err != nil {
		logger.Warning("rate limit: marshal failed:", err)
		return
	}
	path := xray.GetRateLimitPath()
	tmp, err := os.CreateTemp(filepath.Dir(path), ".ratelimit-*.json")
	if err != nil {
		logger.Warning("rate limit: temp file failed:", err)
		return
	}
	tmpName := tmp.Name()
	defer os.Remove(tmpName)
	if _, err := tmp.Write(raw); err != nil {
		tmp.Close()
		logger.Warning("rate limit: write failed:", err)
		return
	}
	if err := tmp.Close(); err != nil {
		logger.Warning("rate limit: close failed:", err)
		return
	}
	if err := os.Chmod(tmpName, 0o600); err != nil {
		logger.Warning("rate limit: chmod failed:", err)
	}
	if err := os.Rename(tmpName, path); err != nil {
		logger.Warning("rate limit: rename failed:", err)
	}
}
