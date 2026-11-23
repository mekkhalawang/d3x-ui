package sub

import (
	"fmt"
	"net"
	"strconv"
	"strings"
)

// pickRealitySNI chooses the SNI a REALITY share link or subscription entry
// presents. Deterministic priority, never random:
//
//  1. realitySettings.settings.serverName — the explicit client-side override
//     the panel exposes on the client settings block;
//  2. the host part of realitySettings.target (alias dest) — the camouflage
//     endpoint the REALITY handshake dials, the only name guaranteed to route
//     through the fallback and answer with the expected certificate;
//  3. serverNames[0] — the inbound's first declared server name, last resort.
//
// The old code picked a random serverNames entry; on inbounds whose server
// names don't all route to the same fallback certificate that silently broke
// a share of the generated links (a client then reports "received real
// certificate"). shortIds keep their random pick — that one is harmless.
func pickRealitySNI(realitySettings map[string]any) string {
	if realitySettings == nil {
		return ""
	}
	if inner, ok := realitySettings["settings"].(map[string]any); ok {
		if sn := realityScalarString(inner["serverName"]); sn != "" {
			return sn
		}
	}
	if host := realityTargetHost(realitySettings); host != "" {
		return host
	}
	if names, ok := realitySettings["serverNames"].([]any); ok && len(names) > 0 {
		return realityScalarString(names[0])
	}
	return ""
}

// realityTargetHost returns the host part of the REALITY target/dest value
// ("host:port" on the wire). Returns "" when the value carries no usable
// host — a bare ":443" or a port-only "443" — so the caller can fall through
// to serverNames[0].
func realityTargetHost(realitySettings map[string]any) string {
	raw := realityScalarString(realitySettings["target"])
	if raw == "" {
		raw = realityScalarString(realitySettings["dest"])
	}
	if raw == "" {
		return ""
	}
	if host, _, err := net.SplitHostPort(raw); err == nil {
		return strings.TrimSpace(host)
	}
	// SplitHostPort rejected the value ("missing port" for a bare host).
	// A value that is only digits is a port number, not a hostname.
	if _, err := strconv.Atoi(raw); err == nil {
		return ""
	}
	return raw
}

// realityScalarString normalises a decoded JSON scalar to a trimmed string;
// nil and empty values collapse to "".
func realityScalarString(v any) string {
	switch t := v.(type) {
	case nil:
		return ""
	case string:
		return strings.TrimSpace(t)
	default:
		return strings.TrimSpace(fmt.Sprint(t))
	}
}
