package database

import (
	"path/filepath"
	"testing"

	"github.com/mekkhalawang/d3x-ui/v3/internal/database/model"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// The one-click Argo wizard used to create inbounds without stamping user_id,
// leaving them on user_id=0 where the user-scoped inbounds list never shows
// them. The migration re-homes those rows onto the panel's first user.
func TestMigrateOrphanInboundUserIds(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "d3x-ui.db")
	legacy, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		t.Fatalf("open legacy db: %v", err)
	}
	if err := legacy.AutoMigrate(&model.User{}, &model.Inbound{}); err != nil {
		t.Fatalf("create legacy schema: %v", err)
	}
	seed := []model.User{
		{Id: 1, Username: "admin", Password: "x"},
		{Id: 2, Username: "second", Password: "y"},
	}
	if err := legacy.Create(&seed).Error; err != nil {
		t.Fatalf("seed users: %v", err)
	}
	inbounds := []model.Inbound{
		{UserId: 0, Remark: "orphan-argo", Enable: true, Port: 20001, Protocol: model.VLESS, Settings: `{"clients":[]}`, StreamSettings: "{}", Tag: "in-argo-quick-20001"},
		{UserId: 2, Remark: "owned-by-second", Enable: true, Port: 20002, Protocol: model.VLESS, Settings: `{"clients":[]}`, StreamSettings: "{}", Tag: "in-20002"},
	}
	if err := legacy.Create(&inbounds).Error; err != nil {
		t.Fatalf("seed inbounds: %v", err)
	}
	sqlDB, err := legacy.DB()
	if err != nil {
		t.Fatalf("legacy db handle: %v", err)
	}
	if err := sqlDB.Close(); err != nil {
		t.Fatalf("close legacy db: %v", err)
	}

	if err := InitDB(dbPath); err != nil {
		t.Fatalf("InitDB: %v", err)
	}
	t.Cleanup(func() { _ = CloseDB() })

	var orphan model.Inbound
	if err := GetDB().Where("tag = ?", "in-argo-quick-20001").First(&orphan).Error; err != nil {
		t.Fatalf("orphan inbound lost: %v", err)
	}
	if orphan.UserId != 1 {
		t.Fatalf("orphan inbound should land on first user (1), got user_id=%d", orphan.UserId)
	}

	var second model.Inbound
	if err := GetDB().Where("tag = ?", "in-20002").First(&second).Error; err != nil {
		t.Fatalf("second-user inbound lost: %v", err)
	}
	if second.UserId != 2 {
		t.Fatalf("owned inbound must keep its owner, got user_id=%d", second.UserId)
	}

	// Idempotent: a second run must not reassign anything.
	if err := migrateOrphanInboundUserIds(); err != nil {
		t.Fatalf("idempotent migrate: %v", err)
	}
	if err := GetDB().Where("tag = ?", "in-20002").First(&second).Error; err != nil {
		t.Fatalf("re-read inbound: %v", err)
	}
	if second.UserId != 2 {
		t.Fatalf("idempotent run moved an owned inbound to user_id=%d", second.UserId)
	}
}
