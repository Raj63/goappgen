// Package plugin provides plugin registration and management for goappgen.
package plugin

import (
	"embed"

	"github.com/Raj63/goappgen/internal/generator/plugin/casbin"
	"github.com/Raj63/goappgen/internal/generator/plugin/jwt"
	"github.com/Raj63/goappgen/internal/generator/plugin/metrics"
	"github.com/Raj63/goappgen/internal/generator/plugin/tracing"
)

// Init registers all plugins with the generator.
func Init(templatesFS embed.FS) {
	Register(jwt.New(templatesFS))
	Register(metrics.New(templatesFS))
	Register(tracing.New(templatesFS))
	Register(casbin.New(templatesFS))
}
