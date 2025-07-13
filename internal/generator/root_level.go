package generator

import (
	"fmt"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator/renderer"
)

// RenderRootTemplates renders all templates that should be at the root level of the project.
func RenderRootTemplates(appConfig config.AppConfig, outputBase string) error {
	// Root-level templates that apply to the entire project
	rootTemplates := []string{
		"README.md.tpl",
		"LICENSE.tpl",
		"CHANGELOG.md.tpl",
		"CONTRIBUTING.md.tpl",
		"CODEOWNERS.tpl",
		"Makefile.tpl",
		"shell.nix.tpl",
		"test.sh.tpl",
		"scripts/test.sh.tpl",
		"docker-compose.yml.tpl",
		"air.toml.tpl",
		"go.work.tpl",
	}

	// "go.mod.tpl",
	// "Dockerfile.tpl",
	// "Makefile.app.tpl",
	// "docker-compose.app.yml.tpl",
	// "Dockerfile.dev.tpl",
	for _, template := range rootTemplates {
		if err := renderer.RenderRootTemplate(appConfig, TemplatesFS, outputBase, template); err != nil {
			return fmt.Errorf("root template %s: %w", template, err)
		}
	}
	return nil
}
