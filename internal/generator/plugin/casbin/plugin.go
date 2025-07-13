// Package casbin provides a plugin for Casbin authorization.
package casbin

import (
	"embed"
	"os"
	"path/filepath"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator/renderer"
)

// Plugin implements the Plugin interface for Casbin.
type Plugin struct {
	templatesFS embed.FS
}

// New creates a new Plugin instance.
func New(templatesFS embed.FS) *Plugin {
	return &Plugin{
		templatesFS: templatesFS,
	}
}

// Name returns the name of the plugin.
func (p *Plugin) Name() string {
	return "casbin"
}

// IsEnabled determines if the plugin is enabled for the given app config.
func (p *Plugin) IsEnabled(cfg config.App) bool {
	return cfg.Auth.Type == "casbin"
}

// Run executes the plugin logic for code generation.
func (p *Plugin) Run(cfg config.App, outputPath, _ string) error {
	target := filepath.Join(outputPath, "internal", "auth")
	if err := os.MkdirAll(target, 0700); err != nil {
		return err
	}
	return renderer.RenderTemplate(cfg, p.templatesFS, outputPath, "internal/plugin/casbin/plugin.go.tpl")
}
