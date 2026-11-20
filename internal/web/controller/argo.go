package controller

import (
	"strconv"

	"github.com/mekkhalawang/d3x-ui/v3/internal/web/service"

	"github.com/gin-gonic/gin"
)

type ArgoController struct {
	argoService service.ArgoService
}

func NewArgoController(g *gin.RouterGroup) *ArgoController {
	a := &ArgoController{}
	a.initRouter(g)
	return a
}

func (a *ArgoController) initRouter(g *gin.RouterGroup) {
	g.GET("/status", a.status)
	g.POST("/config", a.saveConfig)
	g.POST("/createNode", a.createNode)
	g.POST("/quick/start", a.startQuick)
	g.POST("/quick/stop", a.stopQuick)
	g.POST("/named/start", a.startNamed)
	g.POST("/named/stop", a.stopNamed)
	g.POST("/syncHosts", a.syncHosts)
	g.GET("/links/:inboundId", a.links)
}

func (a *ArgoController) createNode(c *gin.Context) {
	var req service.ArgoCreateNodeRequest
	if err := c.ShouldBind(&req); err != nil {
		jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.createNode"), err)
		return
	}
	result, err := a.argoService.CreateNode(req, resolveHost(c))
	if err != nil {
		jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.createNode"), result, err)
		return
	}
	jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.createNode"), result, nil)
}

func (a *ArgoController) status(c *gin.Context) {
	jsonObj(c, a.argoService.Status(), nil)
}

func (a *ArgoController) saveConfig(c *gin.Context) {
	var cfg service.ArgoConfig
	if err := c.ShouldBind(&cfg); err != nil {
		jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.save"), err)
		return
	}
	if err := a.argoService.SaveConfig(cfg); err != nil {
		jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.save"), err)
		return
	}
	jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.save"), nil)
}

func (a *ArgoController) startQuick(c *gin.Context) {
	status, err := a.argoService.StartQuick(c.Request.Context())
	if err != nil {
		jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.start"), status, err)
		return
	}
	jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.start"), status, nil)
}

func (a *ArgoController) stopQuick(c *gin.Context) {
	status, err := a.argoService.StopQuick()
	if err != nil {
		jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.stop"), status, err)
		return
	}
	jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.stop"), status, nil)
}

func (a *ArgoController) startNamed(c *gin.Context) {
	status, err := a.argoService.StartNamed(c.Request.Context())
	if err != nil {
		jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.start"), status, err)
		return
	}
	jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.start"), status, nil)
}

func (a *ArgoController) stopNamed(c *gin.Context) {
	status, err := a.argoService.StopNamed()
	if err != nil {
		jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.stop"), status, err)
		return
	}
	jsonMsgObj(c, I18nWeb(c, "pages.argotunnel.toasts.stop"), status, nil)
}

func (a *ArgoController) syncHosts(c *gin.Context) {
	if err := a.argoService.SyncHosts(); err != nil {
		jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.syncHosts"), err)
		return
	}
	jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.syncHosts"), nil)
}

func (a *ArgoController) links(c *gin.Context) {
	inboundId, err := strconv.Atoi(c.Param("inboundId"))
	if err != nil {
		jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.links"), err)
		return
	}
	host := resolveHost(c)
	links, err := a.argoService.ClientLinks(inboundId, host)
	if err != nil {
		jsonMsg(c, I18nWeb(c, "pages.argotunnel.toasts.links"), err)
		return
	}
	jsonObj(c, links, nil)
}
