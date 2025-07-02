package generator

import (
	"bytes"
	"os"
	"path/filepath"
	"text/template"

	"github.com/Raj63/goappgen/internal/config"
)

// GenerateApp generates a Go application scaffold based on the provided App configuration.
// It uses templates from templatesDir and writes the output to outputBase/app.Name.
func GenerateApp(app config.App, templatesDir, outputBase string) error {
	appPath := filepath.Join(outputBase, "app", app.Name)
	if err := os.MkdirAll(appPath, 0750); err != nil {
		return err
	}

	// Always render these
	commonTpls := []string{
		"main.go.tpl",
		"Dockerfile.tpl",
		"go.mod.tpl",
		"Makefile.tpl",
		"air.toml.tpl",
	}
	for _, tpl := range commonTpls {
		if err := renderTemplate(app, templatesDir, appPath, tpl); err != nil {
			return err
		}
	}

	// Config template
	if app.Config.Type != "" {
		confDir := filepath.Join(appPath, "configs")
		_ = os.MkdirAll(confDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "configs/config.go.tpl")
	}

	// Logger
	if app.Logger.Type != "" {
		loggerDir := filepath.Join(appPath, "internal", "logger")
		_ = os.MkdirAll(loggerDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/logger/logger.go.tpl")
	}

	// DB
	if app.Database.Type != "" {
		dbDir := filepath.Join(appPath, "internal", "db")
		_ = os.MkdirAll(dbDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/db/init.go.tpl")
	}

	return nil
}

func renderTemplate(app config.App, templatesDir, appPath, tplName string) error {
	tplPath := filepath.Join(templatesDir, tplName)
	// #nosec G304
	tplData, err := os.ReadFile(tplPath)
	if err != nil {
		return err
	}

	tpl, err := template.New(tplName).Parse(string(tplData))
	if err != nil {
		return err
	}

	var buf bytes.Buffer
	if err := tpl.Execute(&buf, app); err != nil {
		return err
	}

	outputPath := filepath.Join(appPath, tplName[:len(tplName)-4])
	return os.WriteFile(outputPath, buf.Bytes(), 0600)
}
