package job

import (
	"github.com/mekkhalawang/d3x-ui/v3/internal/logger"
	"github.com/mekkhalawang/d3x-ui/v3/internal/web/service"
)

// ArgoJob keeps the cloudflared tunnels aligned with the panel settings: it
// starts what should run, stops what should not, and heals a runner that gave
// up after its crash-restart budget. The heavy lifting (parsing the quick
// tunnel's domain, syncing share-link hosts) lives in the service layer.
type ArgoJob struct {
	argoService service.ArgoService
}

// NewArgoJob creates the argo reconcile job.
func NewArgoJob() *ArgoJob {
	return new(ArgoJob)
}

// Run reconciles the tunnel runners with the persisted configuration and keeps
// the Argo share-link host rows in step with the discovered domains.
func (j *ArgoJob) Run() {
	j.argoService.Reconcile()
	if err := j.argoService.SyncHosts(); err != nil {
		logger.Warning("argo job: sync hosts failed:", err)
	}
}
