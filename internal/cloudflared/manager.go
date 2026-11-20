// Package cloudflared supervises the cloudflared binary that carries Argo
// (Cloudflare Tunnel) traffic for the panel. Two tunnel kinds run side by side,
// mirroring the layout x-ui-yg popularized:
//
//   - quick:  `cloudflared tunnel --url http://127.0.0.1:<port>` — a throwaway
//     tunnel that gets a random *.trycloudflare.com hostname on every start.
//   - named:  `cloudflared tunnel run --token <token>` — a remotely managed
//     tunnel created in the Cloudflare Zero Trust dashboard; its hostname
//     mapping lives on Cloudflare's side and the domain is configured in the
//     panel.
//
// Both tunnels point at a local WebSocket inbound (the panel's job is only to
// keep the process alive and report the domain); Cloudflare's edge fronts the
// traffic and multi-user auth stays with Xray on the inbound's clients.
package cloudflared

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/mekkhalawang/d3x-ui/v3/internal/config"
	"github.com/mekkhalawang/d3x-ui/v3/internal/logger"
)

const (
	KindQuick = "quick"
	KindNamed = "named"

	logTailMax   = 200
	restartLimit = 5
)

// GetBinaryName returns the cloudflared filename for this platform.
func GetBinaryName() string {
	name := "cloudflared"
	if runtime.GOOS == "windows" {
		name += ".exe"
	}
	return name
}

// GetBinaryPath is where the binary lives, alongside Xray's. XUI_CLOUDFLARED_PATH
// overrides it for operators who install cloudflared themselves.
func GetBinaryPath() string {
	if p := os.Getenv("XUI_CLOUDFLARED_PATH"); p != "" {
		return p
	}
	return config.GetBinFolderPath() + "/" + GetBinaryName()
}

// BinaryURL is the upstream release asset for this platform.
func BinaryURL() (string, error) {
	var arch string
	switch runtime.GOARCH {
	case "amd64":
		arch = "amd64"
	case "arm64":
		arch = "arm64"
	default:
		return "", fmt.Errorf("unsupported arch %s", runtime.GOARCH)
	}
	name := "cloudflared-linux-" + arch
	if runtime.GOOS == "windows" {
		name = "cloudflared-windows-" + arch + ".exe"
	} else if runtime.GOOS == "darwin" {
		name = "cloudflared-darwin-" + arch + ".tgz"
	}
	return "https://github.com/cloudflare/cloudflared/releases/latest/download/" + name, nil
}

// Download fetches the official binary into GetBinaryPath(). Linux assets are a
// bare executable; the macOS tarball is not unpacked here (operators can set
// XUI_CLOUDFLARED_PATH instead).
func Download(ctx context.Context) error {
	path := GetBinaryPath()
	if runtime.GOOS == "darwin" && os.Getenv("XUI_CLOUDFLARED_PATH") == "" {
		return errors.New("download the macOS cloudflared yourself and set XUI_CLOUDFLARED_PATH")
	}
	url, err := BinaryURL()
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("download %s: status %d", url, resp.StatusCode)
	}
	tmp := path + ".download"
	f, err := os.Create(tmp)
	if err != nil {
		return err
	}
	if _, err := io.Copy(f, resp.Body); err != nil {
		f.Close()
		os.Remove(tmp)
		return err
	}
	if err := f.Close(); err != nil {
		os.Remove(tmp)
		return err
	}
	if err := os.Chmod(tmp, 0o755); err != nil {
		os.Remove(tmp)
		return err
	}
	if err := os.Rename(tmp, path); err != nil {
		os.Remove(tmp)
		return err
	}
	logger.Info("cloudflared downloaded to ", path)
	return nil
}

// Version returns the binary's self-reported version, or "" when unavailable.
func Version() string {
	bin := GetBinaryPath()
	if _, err := os.Stat(bin); err != nil {
		return ""
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	out, err := exec.CommandContext(ctx, bin, "version").Output()
	if err != nil {
		return ""
	}
	fields := strings.Fields(string(out))
	if len(fields) >= 3 {
		return fields[2]
	}
	return strings.TrimSpace(string(out))
}

// Status is a snapshot of one tunnel runner.
type Status struct {
	Kind       string   `json:"kind"`
	Running    bool     `json:"running"`
	Domain     string   `json:"domain"`
	OriginPort int      `json:"originPort"`
	Err        string   `json:"err"`
	Restarts   int      `json:"restarts"`
	StartedAt  int64    `json:"startedAt"`
	Log        []string `json:"log"`
}

// runner owns one cloudflared child process: it restarts it after a crash with
// backoff, tails its output into a ring buffer, and — for quick tunnels —
// harvests the *.trycloudflare.com hostname from the startup banner.
type runner struct {
	kind        string
	mu          sync.Mutex
	cmd         *exec.Cmd
	cancel      context.CancelFunc
	intentional atomic.Bool
	log         []string
	domain      string
	originPort  int
	lastErr     string
	restarts    int
	startedAt   time.Time
	args        func() ([]string, error) // build argv; error = "cannot start yet"
	onDomain    func(string)            // quick tunnels persist their domain here
}

func (r *runner) pushLog(line string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.log = append(r.log, line)
	if len(r.log) > logTailMax {
		r.log = r.log[len(r.log)-logTailMax:]
	}
	// Quick tunnels print "https://<name>.trycloudflare.com" on startup.
	if r.kind == KindQuick && r.domain == "" && strings.Contains(line, ".trycloudflare.com") {
		for _, field := range strings.Fields(line) {
			field = strings.Trim(field, "'\"")
			if strings.HasPrefix(field, "https://") && strings.Contains(field, ".trycloudflare.com") {
				r.domain = strings.TrimPrefix(field, "https://")
				if r.onDomain != nil {
					r.onDomain(r.domain)
				}
				break
			}
		}
	}
}

func (r *runner) Status() Status {
	r.mu.Lock()
	defer r.mu.Unlock()
	st := Status{
		Kind:       r.kind,
		Domain:     r.domain,
		OriginPort: r.originPort,
		Err:        r.lastErr,
		Restarts:   r.restarts,
		Log:        append([]string(nil), r.log...),
	}
	if r.cmd != nil && r.cmd.Process != nil {
		st.Running = true
	}
	if !r.startedAt.IsZero() {
		st.StartedAt = r.startedAt.Unix()
	}
	return st
}

// Start launches the child. Safe to call when already running.
func (r *runner) Start() error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.cmd != nil && r.cmd.Process != nil {
		return nil
	}
	args, err := r.args()
	if err != nil {
		r.lastErr = err.Error()
		return err
	}
	bin := GetBinaryPath()
	if _, err := os.Stat(bin); err != nil {
		r.lastErr = "cloudflared binary missing: " + bin
		return errors.New(r.lastErr)
	}
	r.intentional.Store(false)
	ctx, cancel := context.WithCancel(context.Background())
	cmd := exec.CommandContext(ctx, bin, args...)
	stdout, _ := cmd.StdoutPipe()
	stderr, _ := cmd.StderrPipe()
	if err := cmd.Start(); err != nil {
		cancel()
		r.lastErr = err.Error()
		return err
	}
	r.cmd, r.cancel = cmd, cancel
	r.startedAt = time.Now()
	r.lastErr = ""
	logger.Info("cloudflared ", r.kind, " tunnel started (pid ", cmd.Process.Pid, ")")
	go r.drain(stdout)
	go r.drain(stderr)
	go r.wait()
	return nil
}

func (r *runner) drain(rd io.Reader) {
	sc := bufio.NewScanner(rd)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024)
	for sc.Scan() {
		line := sc.Text()
		r.pushLog(line)
		if strings.Contains(line, "ERR") || strings.Contains(line, "error") {
			logger.Warning("cloudflared ", r.kind, ": ", line)
		}
	}
}

// wait reaps the child and, unless the panel stopped it on purpose, schedules a
// bounded restart with backoff.
func (r *runner) wait() {
	r.mu.Lock()
	cmd := r.cmd
	r.mu.Unlock()
	if cmd == nil {
		return
	}
	err := cmd.Wait()
	r.mu.Lock()
	r.cmd = nil
	if r.cancel != nil {
		r.cancel()
		r.cancel = nil
	}
	if r.intentional.Load() {
		r.mu.Unlock()
		return
	}
	if err != nil {
		r.lastErr = err.Error()
	}
	r.mu.Unlock()
	r.scheduleRestart()
}

func (r *runner) scheduleRestart() {
	r.mu.Lock()
	r.restarts++
	n := r.restarts
	r.mu.Unlock()
	if n > restartLimit {
		r.pushLog(fmt.Sprintf("giving up after %d restarts", restartLimit))
		logger.Error("cloudflared ", r.kind, " tunnel gave up after ", n, " restarts")
		return
	}
	backoff := time.Duration(1<<(n-1)) * 5 * time.Second
	if backoff > time.Minute {
		backoff = time.Minute
	}
	logger.Warning("cloudflared ", r.kind, " tunnel exited; restarting in ", backoff)
	time.Sleep(backoff)
	r.mu.Lock()
	stopped := r.intentional.Load()
	r.mu.Unlock()
	if stopped {
		return
	}
	if err := r.Start(); err != nil {
		r.pushLog("restart failed: " + err.Error())
	}
}

// Stop terminates the child and disables auto-restart until the next Start.
func (r *runner) Stop() {
	r.mu.Lock()
	r.intentional.Store(true)
	cancel := r.cancel
	running := r.cmd != nil
	r.mu.Unlock()
	if cancel != nil {
		cancel() // CommandContext kills the child; wait() reaps it
	}
	if running {
		for i := 0; i < 30; i++ {
			r.mu.Lock()
			gone := r.cmd == nil
			r.mu.Unlock()
			if gone {
				break
			}
			time.Sleep(100 * time.Millisecond)
		}
	}
	logger.Info("cloudflared ", r.kind, " tunnel stopped")
}

// Manager supervises both tunnels as a panel-wide singleton.
type Manager struct {
	mu         sync.Mutex
	quick      *runner
	named      *runner
	quickCfg   func() (originPort int, ok bool)
	namedCfg   func() (token string, domain string, originPort int, ok bool)
	onDomain   func(kind, domain string)
}

var (
	managerOnce sync.Once
	managerInst *Manager
)

// GetManager returns the process-wide manager.
func GetManager() *Manager {
	managerOnce.Do(func() {
		managerInst = &Manager{}
	})
	return managerInst
}

// Configure wires the settings providers the manager calls on every (re)start.
// originPort is the local WS inbound port cloudflared points at.
func (m *Manager) Configure(
	quickCfg func() (originPort int, ok bool),
	namedCfg func() (token, domain string, originPort int, ok bool),
	onDomain func(kind, domain string),
) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.quickCfg, m.namedCfg, m.onDomain = quickCfg, namedCfg, onDomain
	if m.quick == nil {
		m.quick = &runner{kind: KindQuick, args: m.quickArgs, onDomain: func(d string) {
			m.notifyDomain(KindQuick, d)
		}}
	}
	if m.named == nil {
		m.named = &runner{kind: KindNamed, args: m.namedArgs}
	}
}

func (m *Manager) notifyDomain(kind, domain string) {
	m.mu.Lock()
	cb := m.onDomain
	m.mu.Unlock()
	if cb != nil {
		cb(kind, domain)
	}
}

func (m *Manager) quickArgs() ([]string, error) {
	m.mu.Lock()
	cfg := m.quickCfg
	m.mu.Unlock()
	if cfg == nil {
		return nil, errors.New("argo is not configured")
	}
	port, ok := cfg()
	if !ok {
		return nil, errors.New("select a WebSocket inbound for the quick tunnel first")
	}
	return []string{"tunnel", "--url", fmt.Sprintf("http://127.0.0.1:%d", port),
		"--edge-ip-version", "auto", "--no-autoupdate", "--protocol", "http2"}, nil
}

func (m *Manager) namedArgs() ([]string, error) {
	m.mu.Lock()
	cfg := m.namedCfg
	m.mu.Unlock()
	if cfg == nil {
		return nil, errors.New("argo is not configured")
	}
	token, _, _, ok := cfg()
	if !ok {
		return nil, errors.New("paste a Cloudflare tunnel token first")
	}
	return []string{"tunnel", "--no-autoupdate", "--edge-ip-version", "auto",
		"--protocol", "http2", "run", "--token", token}, nil
}

// StartQuick launches the temporary tunnel. If binary is missing, downloads it.
func (m *Manager) StartQuick(ctx context.Context) error {
	if err := ensureBinary(ctx); err != nil {
		return err
	}
	return m.quick.Start()
}

// StartNamed launches the token-mode tunnel.
func (m *Manager) StartNamed(ctx context.Context) error {
	if err := ensureBinary(ctx); err != nil {
		return err
	}
	return m.named.Start()
}

func ensureBinary(ctx context.Context) error {
	path := GetBinaryPath()
	if _, err := os.Stat(path); err == nil {
		return nil
	}
	if os.Getenv("XUI_CLOUDFLARED_PATH") != "" {
		return errors.New("cloudflared not found at " + path)
	}
	return Download(ctx)
}

// StopQuick stops the temporary tunnel.
func (m *Manager) StopQuick() { m.quick.Stop() }

// StopNamed stops the named tunnel.
func (m *Manager) StopNamed() { m.named.Stop() }

// Status returns both tunnels' snapshots.
func (m *Manager) Status() (quick Status, named Status) {
	return m.quick.Status(), m.named.Status()
}

// DesiredState lets the reconcile job nudge each tunnel toward what the
// settings say: start what should run, stop what should not.
func (m *Manager) DesiredState(quickWant, namedWant bool) {
	if quickWant {
		if !m.quick.Status().Running {
			_ = m.quick.Start()
		}
	} else {
		m.quick.Stop()
	}
	if namedWant {
		if !m.named.Status().Running {
			_ = m.named.Start()
		}
	} else {
		m.named.Stop()
	}
}
