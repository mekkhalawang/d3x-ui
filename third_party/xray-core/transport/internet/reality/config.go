package reality

import (
	"context"
	"crypto/ecdh"
	"crypto/mldsa"
	"io"
	"net"
	"os"
	"sync"
	"time"

	"github.com/xtls/reality"
	"github.com/xtls/xray-core/common/errors"
	"github.com/xtls/xray-core/transport/internet"
)

// allowX25519Only remembers which REALITY inbounds opted into accepting client
// hellos that carry a plain X25519 key share but no X25519MLKEM768 hybrid share
// (third-party clients such as Shadowrocket / NekoBox). Keyed by the inbound's
// private key.
//
// Only the JSON conf layer can populate this: infra/conf/transport_security.go
// records the choice while parsing config.json, in this very process. The same
// core also takes inbounds over the gRPC API, where the config arrives as a
// protobuf message with no such field — the panel's hot-load path. Those
// inbounds are never registered, so isAllowX25519Only falls back to true and
// they behave exactly like the panel's default. An inbound that explicitly
// opts out is registered as false when the core starts from config.json, and
// keeps that value for the lifetime of the process.
//
// Why a side registry instead of a proto field: reality.Config is a protobuf
// message round-tripped through serial.TypedMessage, so a new field would mean
// regenerating config.pb.go on every kernel upgrade — the maintenance cost the
// ratelimit patch deliberately avoided (docs/d3x-xray-ratelimit.md).
var allowX25519Only sync.Map // string(privateKey) -> bool

// RegisterAllowX25519Only records whether the inbound owning privateKey accepts
// X25519-only REALITY key shares. Called from REALITYConfig.Build at parse time
// — always, so a config re-parse overwrites a stale value for the same key.
func RegisterAllowX25519Only(privateKey []byte, allow bool) {
	allowX25519Only.Store(string(privateKey), allow)
}

// isAllowX25519Only reports whether this inbound accepts X25519-only key shares.
// An unregistered private key is an inbound that arrived over the gRPC API and
// therefore carries no opinion: accept, matching the panel default.
func isAllowX25519Only(privateKey []byte) bool {
	v, ok := allowX25519Only.Load(string(privateKey))
	if !ok {
		return true
	}
	return v.(bool)
}

func (c *Config) GetREALITYConfig() *reality.Config {
	var dialer net.Dialer
	config := &reality.Config{
		DialContext: dialer.DialContext,

		Show: c.Show,
		Type: c.Type,
		Dest: c.Dest,
		Xver: byte(c.Xver),

		MinClientVer: c.MinClientVer,
		MaxClientVer: c.MaxClientVer,
		MaxTimeDiff:  time.Duration(c.MaxTimeDiff) * time.Millisecond,

		NextProtos:             nil, // should be nil
		SessionTicketsDisabled: true,

		KeyLogWriter: KeyLogWriterFromConfig(c),
	}
	var err error
	if config.PrivateKey, err = ecdh.X25519().NewPrivateKey(c.PrivateKey); err != nil {
		panic(err)
	}
	if c.Mldsa65Seed != nil {
		if config.Mldsa65Key, err = mldsa.NewPrivateKey(mldsa.MLDSA65(), c.Mldsa65Seed); err != nil {
			panic(err)
		}
	}
	if c.LimitFallbackUpload != nil {
		config.LimitFallbackUpload.AfterBytes = c.LimitFallbackUpload.AfterBytes
		config.LimitFallbackUpload.BytesPerSec = c.LimitFallbackUpload.BytesPerSec
		config.LimitFallbackUpload.BurstBytesPerSec = c.LimitFallbackUpload.BurstBytesPerSec
	}
	if c.LimitFallbackDownload != nil {
		config.LimitFallbackDownload.AfterBytes = c.LimitFallbackDownload.AfterBytes
		config.LimitFallbackDownload.BytesPerSec = c.LimitFallbackDownload.BytesPerSec
		config.LimitFallbackDownload.BurstBytesPerSec = c.LimitFallbackDownload.BurstBytesPerSec
	}
	config.AllowX25519Only = isAllowX25519Only(c.PrivateKey)
	config.ServerNames = make(map[string]bool)
	for _, serverName := range c.ServerNames {
		config.ServerNames[serverName] = true
	}
	config.ShortIds = make(map[[8]byte]bool)
	for _, shortId := range c.ShortIds {
		config.ShortIds[*(*[8]byte)(shortId)] = true
	}
	return config
}

func KeyLogWriterFromConfig(c *Config) io.Writer {
	if len(c.MasterKeyLog) <= 0 || c.MasterKeyLog == "none" {
		return nil
	}

	writer, err := os.OpenFile(c.MasterKeyLog, os.O_CREATE|os.O_RDWR|os.O_APPEND, 0o600)
	if err != nil {
		errors.LogErrorInner(context.Background(), err, "failed to open ", c.MasterKeyLog, " as master key log")
	}

	return writer
}

func ConfigFromStreamSettings(settings *internet.MemoryStreamConfig) *Config {
	if settings == nil {
		return nil
	}
	config, ok := settings.SecuritySettings.(*Config)
	if !ok {
		return nil
	}
	return config
}
