package service

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/mekkhalawang/d3x-ui/v3/internal/cloudflared"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database"
	"github.com/mekkhalawang/d3x-ui/v3/internal/database/model"
	"github.com/mekkhalawang/d3x-ui/v3/internal/logger"
)

// ArgoConfig is the panel-side Argo tunnel configuration. Quick tunnels get a
// random *.trycloudflare.com hostname per start; named tunnels are remotely
// managed tokens from the Cloudflare Zero Trust dashboard.
type ArgoConfig struct {
	QuickEnable    bool   `json:"quickEnable" form:"quickEnable"`
	QuickInboundId int    `json:"quickInboundId" form:"quickInboundId"`
	QuickDomain    string `json:"quickDomain" form:"quickDomain"`
	NamedEnable    bool   `json:"namedEnable" form:"namedEnable"`
	NamedToken     string `json:"namedToken" form:"namedToken"`
	NamedDomain    string `json:"namedDomain" form:"namedDomain"`
	NamedInboundId int    `json:"namedInboundId" form:"namedInboundId"`
	CdnAddress     string `json:"cdnAddress" form:"cdnAddress"`
}

// ArgoStatus is the API snapshot: config plus both tunnel runners.
type ArgoStatus struct {
	Config     ArgoConfig        `json:"config"`
	Quick      cloudflared.Status `json:"quick"`
	Named      cloudflared.Status `json:"named"`
	BinaryPath string            `json:"binaryPath"`
	Version    string            `json:"version"`
}

// ArgoClientLinks lists one client's share links; the host-synced Argo variants
// are included because LinksForClient expands the inbound's host rows.
type ArgoClientLinks struct {
	Email string   `json:"email"`
	Links []string `json:"links"`
}

const (
	argoGroupQuickTLS  = "argo-quick-tls"
	argoGroupQuickWS   = "argo-quick-ws"
	argoGroupNamedTLS  = "argo-named-tls"
	argoGroupNamedWS   = "argo-named-ws"
	argoLinkPortTLS    = 8443
	argoLinkPortPlain  = 8880
)

type ArgoService struct {
	settingService SettingService
}

var argoWired bool

// wireManager connects the cloudflared supervisor to the settings providers.
// Idempotent; called from every public entry point and the reconcile job.
func (s *ArgoService) wireManager() {
	mgr := cloudflared.GetManager()
	mgr.Configure(
		func() (int, bool) {
			cfg := s.GetConfig()
			if !cfg.QuickEnable {
				return 0, false
			}
			port, err := s.inboundOriginPort(cfg.QuickInboundId)
			if err != nil {
				return 0, false
			}
			return port, true
		},
		func() (string, string, int, bool) {
			cfg := s.GetConfig()
			if !cfg.NamedEnable || strings.TrimSpace(cfg.NamedToken) == "" {
				return "", "", 0, false
			}
			port, err := s.inboundOriginPort(cfg.NamedInboundId)
			if err != nil {
				port = 0 // named tunnels may route inside the CF dashboard
			}
			return strings.TrimSpace(cfg.NamedToken), cfg.NamedDomain, port, true
		},
		func(kind, domain string) {
			cfg := s.GetConfig()
			switch kind {
			case cloudflared.KindQuick:
				cfg.QuickDomain = domain
			case cloudflared.KindNamed:
				cfg.NamedDomain = domain
			}
			if err := s.saveConfig(cfg); err != nil {
				logger.Warning("argo: persist discovered domain:", err)
			}
			logger.Info("argo: ", kind, " tunnel domain ", domain)
			if err := s.SyncHosts(); err != nil {
				logger.Warning("argo: host sync after domain discovery:", err)
			}
		},
	)
	argoWired = true
}

// GetConfig reads the persisted configuration.
func (s *ArgoService) GetConfig() ArgoConfig {
	get := func(key, def string) string {
		v, err := s.settingService.getString(key)
		if err != nil {
			return def
		}
		return v
	}
	return ArgoConfig{
		QuickEnable:    get("argoQuickEnable", "false") == "true",
		QuickInboundId: atoiOr(get("argoQuickInboundId", "0")),
		QuickDomain:    get("argoQuickDomain", ""),
		NamedEnable:    get("argoNamedEnable", "false") == "true",
		NamedToken:     get("argoNamedToken", ""),
		NamedDomain:    get("argoNamedDomain", ""),
		NamedInboundId: atoiOr(get("argoNamedInboundId", "0")),
		CdnAddress:     get("argoCdnAddress", "www.visa.com.sg"),
	}
}

func atoiOr(s string) int {
	n, _ := strconv.Atoi(strings.TrimSpace(s))
	return n
}

func (s *ArgoService) saveConfig(cfg ArgoConfig) error {
	vals := map[string]string{
		"argoQuickEnable":    strconv.FormatBool(cfg.QuickEnable),
		"argoQuickInboundId": strconv.Itoa(cfg.QuickInboundId),
		"argoQuickDomain":    cfg.QuickDomain,
		"argoNamedEnable":    strconv.FormatBool(cfg.NamedEnable),
		"argoNamedToken":     cfg.NamedToken,
		"argoNamedDomain":    cfg.NamedDomain,
		"argoNamedInboundId": strconv.Itoa(cfg.NamedInboundId),
		"argoCdnAddress":     cfg.CdnAddress,
	}
	for k, v := range vals {
		if err := s.settingService.setString(k, v); err != nil {
			return err
		}
	}
	return nil
}

// SaveConfig stores the configuration after validating the bound inbounds and
// re-syncs the Argo host rows so share links follow the change.
func (s *ArgoService) SaveConfig(cfg ArgoConfig) error {
	if cfg.CdnAddress == "" {
		cfg.CdnAddress = "www.visa.com.sg"
	}
	if cfg.QuickEnable && cfg.QuickInboundId <= 0 {
		return fmt.Errorf("select a WebSocket inbound")
	}
	if cfg.QuickInboundId > 0 {
		if err := s.validateWSInbound(cfg.QuickInboundId); err != nil {
			return err
		}
	}
	if cfg.NamedEnable {
		if strings.TrimSpace(cfg.NamedToken) == "" {
			return fmt.Errorf("named tunnel needs a token from the Cloudflare Zero Trust dashboard")
		}
	}
	if cfg.NamedInboundId > 0 {
		if err := s.validateWSInbound(cfg.NamedInboundId); err != nil {
			return err
		}
	}
	// Reset discovered quick domain: a new config may point at another inbound.
	old := s.GetConfig()
	if old.QuickInboundId != cfg.QuickInboundId {
		cfg.QuickDomain = ""
	}
	if err := s.saveConfig(cfg); err != nil {
		return err
	}
	s.wireManager()
	return s.SyncHosts()
}

// validateWSInbound enforces the Argo preconditions x-ui-yg documents: the
// tunnel fronted inbound must be WebSocket with TLS off, because Cloudflare's
// edge terminates TLS and the local hop stays plain.
func (s *ArgoService) validateWSInbound(inboundId int) error {
	if inboundId <= 0 {
		return fmt.Errorf("select a WebSocket inbound")
	}
	var inbound model.Inbound
	if err := database.GetDB().First(&inbound, inboundId).Error; err != nil {
		return fmt.Errorf("inbound %d not found", inboundId)
	}
	name := strings.TrimSpace(inbound.Remark)
	if name == "" {
		name = fmt.Sprintf("#%d", inbound.Id)
	}
	var stream map[string]any
	_ = json.Unmarshal([]byte(inbound.StreamSettings), &stream)
	network, _ := stream["network"].(string)
	if network != "ws" {
		return fmt.Errorf("inbound '%s' uses %s transport; Argo needs WebSocket", name, network)
	}
	security, _ := stream["security"].(string)
	if security == "tls" || security == "reality" {
		return fmt.Errorf("inbound '%s' has %s enabled; turn it off, Cloudflare's edge terminates TLS", name, security)
	}
	return nil
}

// inboundOriginPort resolves the local port cloudflared points at.
func (s *ArgoService) inboundOriginPort(inboundId int) (int, error) {
	var inbound model.Inbound
	if err := database.GetDB().First(&inbound, inboundId).Error; err != nil {
		return 0, err
	}
	if inbound.Port <= 0 {
		return 0, fmt.Errorf("inbound %d has no port", inboundId)
	}
	return inbound.Port, nil
}

// Status snapshots config and both runners.
func (s *ArgoService) Status() ArgoStatus {
	s.wireManager()
	quick, named := cloudflared.GetManager().Status()
	return ArgoStatus{
		Config:     s.GetConfig(),
		Quick:      quick,
		Named:      named,
		BinaryPath: cloudflared.GetBinaryPath(),
		Version:    cloudflared.Version(),
	}
}

// StartQuick launches the temporary tunnel and returns the status.
func (s *ArgoService) StartQuick(ctx context.Context) (ArgoStatus, error) {
	s.wireManager()
	cfg := s.GetConfig()
	cfg.QuickEnable = true
	if err := s.saveConfig(cfg); err != nil {
		return ArgoStatus{}, err
	}
	if err := s.validateWSInbound(cfg.QuickInboundId); err != nil {
		return ArgoStatus{}, err
	}
	err := cloudflared.GetManager().StartQuick(ctx)
	return s.Status(), err
}

// StopQuick stops the temporary tunnel.
func (s *ArgoService) StopQuick() (ArgoStatus, error) {
	s.wireManager()
	cloudflared.GetManager().StopQuick()
	cfg := s.GetConfig()
	cfg.QuickEnable = false
	if err := s.saveConfig(cfg); err != nil {
		return ArgoStatus{}, err
	}
	return s.Status(), s.SyncHosts()
}

// StartNamed launches the token-mode tunnel.
func (s *ArgoService) StartNamed(ctx context.Context) (ArgoStatus, error) {
	s.wireManager()
	cfg := s.GetConfig()
	cfg.NamedEnable = true
	if err := s.saveConfig(cfg); err != nil {
		return ArgoStatus{}, err
	}
	if cfg.NamedInboundId > 0 {
		if err := s.validateWSInbound(cfg.NamedInboundId); err != nil {
			return ArgoStatus{}, err
		}
	}
	err := cloudflared.GetManager().StartNamed(ctx)
	return s.Status(), err
}

// StopNamed stops the token-mode tunnel.
func (s *ArgoService) StopNamed() (ArgoStatus, error) {
	s.wireManager()
	cloudflared.GetManager().StopNamed()
	cfg := s.GetConfig()
	cfg.NamedEnable = false
	if err := s.saveConfig(cfg); err != nil {
		return ArgoStatus{}, err
	}
	return s.Status(), s.SyncHosts()
}

// Reconcile nudges the runners toward what the settings say. The web layer
// calls it on a timer and once at startup.
func (s *ArgoService) Reconcile() {
	s.wireManager()
	cfg := s.GetConfig()
	cloudflared.GetManager().DesiredState(cfg.QuickEnable, cfg.NamedEnable)
}

// SyncHosts mirrors the active tunnels into Host rows so the subscription and
// share-link machinery emits Argo variants (add = preferred CF IP, host/sni =
// tunnel domain, 8443 wss + 8880 ws) for every client of the bound inbound.
func (s *ArgoService) SyncHosts() error {
	cfg := s.GetConfig()
	type spec struct {
		group   string
		enabled bool
		domain  string
		inbound int
		tls     bool
	}
	specs := []spec{
		{argoGroupQuickTLS, cfg.QuickEnable && cfg.QuickDomain != "", cfg.QuickDomain, cfg.QuickInboundId, true},
		{argoGroupQuickWS, cfg.QuickEnable && cfg.QuickDomain != "", cfg.QuickDomain, cfg.QuickInboundId, false},
		{argoGroupNamedTLS, cfg.NamedEnable && cfg.NamedDomain != "", cfg.NamedDomain, cfg.NamedInboundId, true},
		{argoGroupNamedWS, cfg.NamedEnable && cfg.NamedDomain != "", cfg.NamedDomain, cfg.NamedInboundId, false},
	}
	db := database.GetDB()
	for _, sp := range specs {
		if !sp.enabled || sp.inbound <= 0 {
			// Drop stale rows: the tunnel went away or moved elsewhere.
			if err := db.Where("group_id = ?", sp.group).Delete(&model.Host{}).Error; err != nil {
				return err
			}
			continue
		}
		port := argoLinkPortPlain
		security := "none"
		sni := ""
		if sp.tls {
			port = argoLinkPortTLS
			security = "tls"
			sni = sp.domain
		}
		row := model.Host{
			GroupId:     sp.group,
			InboundId:   sp.inbound,
			Remark:      sp.group,
			Address:     cfg.CdnAddress,
			Port:        port,
			Security:    security,
			Sni:         sni,
			HostHeader:  sp.domain,
			SortOrder:   100,
		}
		var existing model.Host
		err := db.Where("group_id = ?", sp.group).First(&existing).Error
		switch {
		case err == nil:
			if existing.InboundId == row.InboundId && existing.Address == row.Address &&
				existing.Port == row.Port && existing.Security == row.Security &&
				existing.Sni == row.Sni && existing.HostHeader == row.HostHeader &&
				!existing.IsDisabled {
				continue // unchanged, don't churn the row
			}
			existing.InboundId = row.InboundId
			existing.Address = row.Address
			existing.Port = row.Port
			existing.Security = row.Security
			existing.Sni = row.Sni
			existing.HostHeader = row.HostHeader
			existing.IsDisabled = false
			if err := db.Save(&existing).Error; err != nil {
				return err
			}
		case database.IsNotFound(err):
			if err := db.Create(&row).Error; err != nil {
				return err
			}
		default:
			return err
		}
	}
	return nil
}

// ClientLinks returns every client's share links for the inbound, Argo
// variants included once the host rows exist.
func (s *ArgoService) ClientLinks(inboundId int, host string) ([]ArgoClientLinks, error) {
	var inbound model.Inbound
	if err := database.GetDB().First(&inbound, inboundId).Error; err != nil {
		return nil, err
	}
	clients, err := ParseInboundSettingsClients(inbound.Settings)
	if err != nil {
		return nil, err
	}
	provider := subLinkProvider()
	if provider == nil {
		return nil, fmt.Errorf("link provider not ready")
	}
	out := make([]ArgoClientLinks, 0, len(clients))
	for _, client := range clients {
		email := strings.TrimSpace(client.Email)
		if email == "" || !client.Enable {
			continue
		}
		links := provider.LinksForClient(host, &inbound, email)
		if len(links) == 0 {
			continue
		}
		out = append(out, ArgoClientLinks{Email: email, Links: links})
	}
	return out, nil
}
