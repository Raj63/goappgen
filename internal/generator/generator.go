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
	appPath := filepath.Join(outputBase, app.Name)
	err := os.MkdirAll(appPath, 0750)
	if err != nil {
		return err
	}

	files := []string{"main.go.tpl", "Dockerfile.tpl"}
	for _, fname := range files {
		if err := renderTemplate(app, templatesDir, appPath, fname); err != nil {
			return err
		}
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
