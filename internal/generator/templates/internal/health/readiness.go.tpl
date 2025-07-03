package health

import (
	{{- if eq .Transport.HTTPFramework "gin" }}
	"github.com/gin-gonic/gin"
	{{- else if eq .Transport.HTTPFramework "echo" }}
	"github.com/labstack/echo/v4"
	{{- else if eq .Transport.HTTPFramework "chi" }}
	"net/http"
	{{- end }}
)

// ReadinessHandler returns a readiness check handler for the selected HTTP framework.
func ReadinessHandler() interface{} {
	{{- if eq .Transport.HTTPFramework "gin" }}
	return func(c *gin.Context) { c.JSON(200, gin.H{"status": "ready"}) }
	{{- else if eq .Transport.HTTPFramework "echo" }}
	return func(c echo.Context) error { return c.JSON(200, map[string]string{"status": "ready"}) }
	{{- else if eq .Transport.HTTPFramework "chi" }}
	return func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ready")) }
	{{- else }}
	return nil
	{{- end }}
}
