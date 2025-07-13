// Package metrics provides a plugin for metrics instrumentation.
package metrics

import (
	"embed"
	"os"
	"path/filepath"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator/renderer"
)

// Plugin implements the Plugin interface for metrics.
type Plugin struct {
	templatesFS embed.FS
}

// New creates a new MetricsPlugin instance.
func New(templatesFS embed.FS) *Plugin {
	return &Plugin{
		templatesFS: templatesFS,
	}
}

// Name returns the name of the plugin.
func (p *Plugin) Name() string {
	return "metrics"
}

// IsEnabled determines if the plugin is enabled for the given app config.
func (p *Plugin) IsEnabled(cfg config.App) bool {
	return cfg.Observability.Metrics.Enabled
}

// Run executes the plugin logic for code generation.
func (p *Plugin) Run(cfg config.App, outputPath, _ string) error {
	target := filepath.Join(outputPath, "internal", "metrics")
	_ = os.MkdirAll(target, 0750)
	return renderer.RenderTemplate(cfg, p.templatesFS, target, "plugin/metrics/metrics.go.tpl")
}
