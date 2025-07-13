// Package generator provides the logic for generating Go application scaffolding from templates.
package generator

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator/plugin"
	"github.com/Raj63/goappgen/internal/generator/renderer"
)

// GenerateAllWithPostGen wraps GenerateAll and optionally runs Go workspace commands after generation.
func GenerateAllWithPostGen(appConfig config.AppConfig, outputBase string, syncGoMod, dryRun bool) error {
	if dryRun {
		return printFileStructure(appConfig, outputBase)
	}
	if err := GenerateAll(appConfig, outputBase); err != nil {
		return err
	}
	if !syncGoMod {
		return nil
	}
	// Always run go work sync in the output root
	cmd := exec.Command("go", "work", "sync")
	cmd.Dir = outputBase
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}

// GenerateAll generates the full project structure (always multi-app style) based on the provided AppConfig.
func GenerateAll(appConfig config.AppConfig, outputBase string) error {
	// Ensure output directory exists
	if err := os.MkdirAll(outputBase, 0750); err != nil {
		return err
	}

	if len(appConfig.App) < 1 {
		return nil
	}
	// Render all root-level templates
	if err := RenderRootTemplates(appConfig, outputBase); err != nil {
		return fmt.Errorf("root templates: %w", err)
	}

	// Generate each app in apps/<appname>
	for _, app := range appConfig.App {
		appPath := filepath.Join(outputBase, "apps", app.Name)
		if err := GenerateApp(app, appPath); err != nil {
			return fmt.Errorf("app %s: %w", app.Name, err)
		}
		// After common templates...
		for _, pl := range plugin.Plugins {
			if pl.IsEnabled(app) {
				if err := pl.Run(app, appPath, ""); err != nil {
					return fmt.Errorf("plugin %s: %w", pl.Name(), err)
				}
			}
		}

		// Kubernetes manifests for each app: output to k8s/<appname>/
		if app.DevTools.Kubernetes {
			k8sDir := filepath.Join(outputBase, "k8s", app.Name)
			err := os.MkdirAll(k8sDir, 0700)
			if err != nil {
				return fmt.Errorf("error creating dir %s: %w", k8sDir, err)
			}
			err = renderer.RenderTemplate(app, TemplatesFS, k8sDir, "k8s/deployment.yaml.tpl")
			if err != nil {
				return fmt.Errorf("error rendering k8s/deployment.yaml: %w", err)
			}
			err = renderer.RenderTemplate(app, TemplatesFS, k8sDir, "k8s/service.yaml.tpl")
			if err != nil {
				return fmt.Errorf("error rendering k8s/service.yaml: %w", err)
			}
			err = renderer.RenderTemplate(app, TemplatesFS, k8sDir, "k8s/ingress.yaml.tpl")
			if err != nil {
				return fmt.Errorf("error rendering k8s/ingress.yaml: %w", err)
			}
		}
	}
	return nil
}
