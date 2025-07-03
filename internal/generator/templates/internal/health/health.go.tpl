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

// HealthHandler returns a health check handler for the selected HTTP framework.
func HealthHandler() interface{} {
	{{- if eq .Transport.HTTPFramework "gin" }}
	return func(c *gin.Context) { c.JSON(200, gin.H{"status": "ok"}) }
	{{- else if eq .Transport.HTTPFramework "echo" }}
	return func(c echo.Context) error { return c.JSON(200, map[string]string{"status": "ok"}) }
	{{- else if eq .Transport.HTTPFramework "chi" }}
	return func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok")) }
	{{- else }}
	return nil
	{{- end }}
} 