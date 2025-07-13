// Package jwt provides a plugin for JWT authentication.
package jwt

import (
	"embed"
	"os"
	"path/filepath"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator/renderer"
)

// Plugin implements the Plugin interface for JWT.
type Plugin struct {
	templatesFS embed.FS
}

// New creates a new JWTPlugin instance.
func New(templatesFS embed.FS) *Plugin {
	return &Plugin{
		templatesFS: templatesFS,
	}
}

// Name returns the name of the plugin.
func (p *Plugin) Name() string {
	return "jwt"
}

// IsEnabled determines if the plugin is enabled for the given app config.
func (p *Plugin) IsEnabled(cfg config.App) bool {
	return cfg.Auth.Type == "jwt"
}

// Run executes the plugin logic for code generation.
func (p *Plugin) Run(cfg config.App, out, _ string) error {
	dest := filepath.Join(out, "internal", "middleware")
	_ = os.MkdirAll(dest, 0750)
	return renderer.RenderTemplate(cfg, p.templatesFS, dest, "plugin/jwt/jwt_middleware.go.tpl")
}
