package service

import (
	"encoding/json"
	"path/filepath"
	"testing"

	"github.com/mekkhalawang/d3x-ui/v3/internal/database"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database/dbtest"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database/model"
)

func TestUpdateByEmailJSONPersistsSpeedLimits(t *testing.T) {
	dbtest.InitDB(t, filepath.Join(t.TempDir(), "d3x-ui.db"))
	var svc ClientService

	c := model.Client{
		Email:          "slow@x",
		ID:             "11111111-1111-1111-1111-111111111111",
		SubID:          "slow@x",
		Enable:         true,
		SpeedLimitUp:   10000,
		SpeedLimitDown: 50000,
	}
	inbound := mkInbound(t, 443, model.VLESS, clientsSettings(t, []model.Client{c}))
	if err := svc.SyncInbound(nil, inbound.Id, []model.Client{c}); err != nil {
		t.Fatal(err)
	}

	var isvc InboundService
	body, _ := json.Marshal(map[string]any{"speedLimitUp": 20000, "speedLimitDown": 60000})
	if _, err := svc.UpdateByEmailJSON(&isvc, "slow@x", body); err != nil {
		t.Fatalf("update: %v", err)
	}

	var stored model.ClientRecord
	if err := database.GetDB().Where("email = ?", "slow@x").First(&stored).Error; err != nil {
		t.Fatal(err)
	}
	if stored.SpeedLimitUp != 20000 || stored.SpeedLimitDown != 60000 {
		t.Fatalf("ledger speed = %d/%d, want 20000/60000", stored.SpeedLimitUp, stored.SpeedLimitDown)
	}

	var ib model.Inbound
	if err := database.GetDB().First(&ib, inbound.Id).Error; err != nil {
		t.Fatal(err)
	}
	var settings struct {
		Clients []model.Client `json:"clients"`
	}
	if err := json.Unmarshal([]byte(ib.Settings), &settings); err != nil {
		t.Fatal(err)
	}
	if len(settings.Clients) != 1 || settings.Clients[0].SpeedLimitUp != 20000 {
		t.Fatalf("settings clients = %+v", settings.Clients)
	}
}
