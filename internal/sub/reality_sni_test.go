package sub

import "testing"

func TestPickRealitySNI(t *testing.T) {
	for _, tc := range []struct {
		name  string
		input map[string]any
		want  string
	}{
		{
			name:  "nil map",
			input: nil,
			want:  "",
		},
		{
			name:  "empty map",
			input: map[string]any{},
			want:  "",
		},
		{
			name: "explicit settings.serverName wins over target and serverNames",
			input: map[string]any{
				"target":      "download-porter.hoyoverse.com:443",
				"serverNames": []any{"hoyoverse.com", "download-porter.hoyoverse.com"},
				"settings":    map[string]any{"serverName": "pinned.example.com"},
			},
			want: "pinned.example.com",
		},
		{
			name: "blank settings.serverName falls through to target host",
			input: map[string]any{
				"target":      "download-porter.hoyoverse.com:443",
				"serverNames": []any{"hoyoverse.com", "download-porter.hoyoverse.com"},
				"settings":    map[string]any{"serverName": "   "},
			},
			want: "download-porter.hoyoverse.com",
		},
		{
			name: "target host beats serverNames[0]",
			input: map[string]any{
				"target":      "download-porter.hoyoverse.com:443",
				"serverNames": []any{"hoyoverse.com", "download-porter.hoyoverse.com"},
			},
			want: "download-porter.hoyoverse.com",
		},
		{
			name: "legacy dest alias provides the target host",
			input: map[string]any{
				"dest":        "camouflage.example.com:8443",
				"serverNames": []any{"wrong.example.com"},
			},
			want: "camouflage.example.com",
		},
		{
			name: "target wins over dest when both exist",
			input: map[string]any{
				"target": "target.example.com:443",
				"dest":   "dest.example.com:443",
			},
			want: "target.example.com",
		},
		{
			name: "serverNames[0] fallback without target",
			input: map[string]any{
				"serverNames": []any{"first.example.com", "second.example.com"},
			},
			want: "first.example.com",
		},
		{
			name: "target with only a port number falls through",
			input: map[string]any{
				"target":      "443",
				"serverNames": []any{"fallback.example.com"},
			},
			want: "fallback.example.com",
		},
		{
			name: "target with empty host and port falls through",
			input: map[string]any{
				"target":      ":443",
				"serverNames": []any{"fallback.example.com"},
			},
			want: "fallback.example.com",
		},
		{
			name: "bare host without port is used as-is",
			input: map[string]any{
				"target": "bare.example.com",
			},
			want: "bare.example.com",
		},
		{
			name: "ipv6 target keeps the address, not a bracket fragment",
			input: map[string]any{
				"target":      "[2001:db8::1]:443",
				"serverNames": []any{"fallback.example.com"},
			},
			want: "2001:db8::1",
		},
		{
			name: "all-empty settings returns empty",
			input: map[string]any{
				"target":      "",
				"serverNames": []any{},
				"settings":    map[string]any{"serverName": ""},
			},
			want: "",
		},
		{
			name: "non-string serverNames entry is normalised",
			input: map[string]any{
				"serverNames": []any{123},
			},
			want: "123",
		},
		{
			name: "nil settings block does not panic",
			input: map[string]any{
				"settings":    nil,
				"serverNames": []any{"fallback.example.com"},
			},
			want: "fallback.example.com",
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if got := pickRealitySNI(tc.input); got != tc.want {
				t.Errorf("pickRealitySNI(%v) = %q, want %q", tc.input, got, tc.want)
			}
		})
	}
}
