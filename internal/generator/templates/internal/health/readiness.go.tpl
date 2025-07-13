package health

import (
	{{- if eq .Transport.HTTPFramework "gin" }}
	"github.com/gin-gonic/gin"
	{{- else if eq .Transport.HTTPFramework "echo" }}
	"github.com/labstack/echo/v4"
	{{- else if eq .Transport.HTTPFramework "chi" }}
	"net/http"
	{{- end }}
	"os"
	"time"
)

// isAppReady checks all critical dependencies for readiness
func isAppReady() (bool, string) {
	// --- Database check (placeholder) ---
	if !isDatabaseConnected() {
		return false, "database unavailable"
	}
	// --- Cache check (placeholder) ---
	if !isCacheAvailable() {
		return false, "cache unavailable"
	}
	// --- External API check (placeholder) ---
	if !isExternalAPIAvailable() {
		return false, "external API unavailable"
	}
	// --- Disk space check (example) ---
	if !hasSufficientDiskSpace() {
		return false, "insufficient disk space"
	}
	return true, ""
}

// isDatabaseConnected is a placeholder for real DB checks
func isDatabaseConnected() bool {
	// TODO: Implement actual DB check
	return true
}

// isCacheAvailable is a placeholder for real cache checks
func isCacheAvailable() bool {
	// TODO: Implement actual cache (e.g., Redis) check
	return true
}

// isExternalAPIAvailable is a placeholder for real external API checks
func isExternalAPIAvailable() bool {
	// TODO: Implement actual external API check (e.g., ping a service)
	return true
}

// hasSufficientDiskSpace checks if the disk has enough free space (example: >100MB)
func hasSufficientDiskSpace() bool {
	var stat os.FileInfo
	var err error
	stat, err = os.Stat(".")
	if err != nil {
		return false
	}
	// This is a placeholder; use syscall or a library for real disk space checks
	return true
}

// ReadinessHandler returns a readiness check handler for the selected HTTP framework.
// It returns HTTP 200 if all dependencies are ready, or HTTP 503 with a reason if not.
func ReadinessHandler() interface{} {
	{{- if eq .Transport.HTTPFramework "gin" }}
	return func(c *gin.Context) {
		if ok, reason := isAppReady(); !ok {
			c.JSON(503, gin.H{"status": "not ready", "reason": reason})
			return
		}
		c.JSON(200, gin.H{"status": "ready"})
	}
	{{- else if eq .Transport.HTTPFramework "echo" }}
	return func(c echo.Context) error {
		if ok, reason := isAppReady(); !ok {
			return c.JSON(503, map[string]string{"status": "not ready", "reason": reason})
		}
		return c.JSON(200, map[string]string{"status": "ready"})
	}
	{{- else if eq .Transport.HTTPFramework "chi" }}
	return func(w http.ResponseWriter, r *http.Request) {
		if ok, reason := isAppReady(); !ok {
			w.WriteHeader(503)
			w.Write([]byte(`{"status": "not ready", "reason": "` + reason + `"}`))
			return
		}
		w.Write([]byte("ready"))
	}
	{{- else }}
	return nil
	{{- end }}
}
