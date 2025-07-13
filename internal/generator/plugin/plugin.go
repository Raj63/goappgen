package plugin

import (
	"github.com/Raj63/goappgen/internal/config"
)

// Plugin defines a code generation extension
type Plugin interface {
	Name() string
	IsEnabled(cfg config.App) bool
	Run(cfg config.App, outputPath, templatesDir string) error
}

// Plugins holds all registered plugins.
var Plugins []Plugin

// Register adds a plugin to the Plugins list.
func Register(p Plugin) {
	Plugins = append(Plugins, p)
}
