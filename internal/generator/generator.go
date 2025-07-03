// Package generator provides the logic for generating Go application scaffolding from templates.
package generator

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"unicode"

	"github.com/Raj63/goappgen/internal/config"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

// GenerateApp generates a Go application scaffold based on the provided App configuration.
// It uses templates from templatesDir and writes the output to outputBase/app.Name.
func GenerateApp(app config.App, templatesDir, appPath string) error {
	if err := os.MkdirAll(appPath, 0750); err != nil {
		return err
	}

	// Always render these
	commonTpls := []string{
		"main.go.tpl",
		"Dockerfile.tpl",
		"go.mod.tpl",
		"Makefile.app.tpl",
		"air.toml.tpl",
		"docker-compose.app.yml.tpl",
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

	// Config YAML
	_ = renderTemplate(app, templatesDir, appPath, "configs/config.yaml.tpl")

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

	// Observability: metrics
	if app.Observability.Metrics != "" {
		obsDir := filepath.Join(appPath, "internal", "observability")
		_ = os.MkdirAll(obsDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/observability/metrics.go.tpl")
	}
	// Observability: tracing
	if app.Observability.Tracing != "" {
		obsDir := filepath.Join(appPath, "internal", "observability")
		_ = os.MkdirAll(obsDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/observability/tracing.go.tpl")
	}
	// Auth
	if app.Auth.Type != "" {
		authDir := filepath.Join(appPath, "internal", "auth")
		_ = os.MkdirAll(authDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/auth/auth.go.tpl")
	}
	// Health
	healthDir := filepath.Join(appPath, "internal", "health")
	_ = os.MkdirAll(healthDir, 0700)
	_ = renderTemplate(app, templatesDir, appPath, "internal/health/health.go.tpl")
	// Readiness
	readinessDir := filepath.Join(appPath, "internal", "health")
	_ = os.MkdirAll(readinessDir, 0700)
	_ = renderTemplate(app, templatesDir, appPath, "internal/health/readiness.go.tpl")
	// Graceful shutdown
	shutdownDir := filepath.Join(appPath, "internal", "shutdown")
	_ = os.MkdirAll(shutdownDir, 0700)
	_ = renderTemplate(app, templatesDir, appPath, "internal/shutdown/shutdown.go.tpl")
	// Loki logging
	if app.Logger.Type == "logrus" || app.Logger.Type == "zap" || app.Logger.Type == "zerolog" {
		loggerDir := filepath.Join(appPath, "internal", "logger")
		_ = os.MkdirAll(loggerDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/logger/loki.go.tpl")
	}

	// Storage
	if app.Storage.Type == "s3" || app.Storage.Type == "minio" {
		storageDir := filepath.Join(appPath, "internal", "storage")
		_ = os.MkdirAll(storageDir, 0700)
		_ = renderTemplate(app, templatesDir, appPath, "internal/storage/storage.go.tpl")
	}

	return nil
}

// helper: convert CamelCase to snake_case
func toSnakeCase(str string) string {
	var result []rune
	for i, r := range str {
		if unicode.IsUpper(r) && i > 0 {
			result = append(result, '_')
		}
		result = append(result, unicode.ToLower(r))
	}
	return string(result)
}

// helper: convert CamelCase to kebab-case
func toKebabCase(str string) string {
	var result []rune
	for i, r := range str {
		if unicode.IsUpper(r) && i > 0 {
			result = append(result, '-')
		}
		result = append(result, unicode.ToLower(r))
	}
	return string(result)
}

func defaultFunc(def, val interface{}) interface{} {
	if val == nil {
		return def
	}
	v, ok := val.(string)
	if ok && v == "" {
		return def
	}
	return val
}

func titleFunc(s string) string {
	return cases.Title(language.Und).String(s)
}

func renderTemplate(app config.App, templatesDir, appPath, tplName string) error {
	tplPath := filepath.Join(templatesDir, tplName)
	// #nosec G304
	tplData, err := os.ReadFile(tplPath)
	if err != nil {
		return err
	}

	funcs := template.FuncMap{
		"ToLower":   strings.ToLower,
		"ToUpper":   strings.ToUpper,
		"SnakeCase": toSnakeCase,
		"KebabCase": toKebabCase,
		"Title":     titleFunc,
		"default":   defaultFunc,
		"add":       func(a, b int) int { return a + b },
	}

	tpl, err := template.New(filepath.Base(tplName)).Funcs(funcs).Parse(string(tplData))
	if err != nil {
		return err
	}

	var buf bytes.Buffer
	if err := tpl.Execute(&buf, app); err != nil {
		return err
	}

	output := filepath.Join(appPath, tplName[:len(tplName)-4])
	if err := os.MkdirAll(filepath.Dir(output), 0750); err != nil {
		return err
	}
	return os.WriteFile(output, buf.Bytes(), 0600)
}

// List of templates that are per-app only and should not be rendered at the root
var perAppTemplates = map[string]struct{}{
	"main.go.tpl":                           {},
	"Dockerfile.tpl":                        {},
	"go.mod.tpl":                            {},
	"Makefile.app.tpl":                      {},
	"air.toml.tpl":                          {},
	"docker-compose.app.yml.tpl":            {},
	"configs/config.go.tpl":                 {},
	"configs/config.yaml.tpl":               {},
	"internal/logger/logger.go.tpl":         {},
	"internal/logger/loki.go.tpl":           {},
	"internal/db/init.go.tpl":               {},
	"internal/observability/metrics.go.tpl": {},
	"internal/observability/tracing.go.tpl": {},
	"internal/auth/auth.go.tpl":             {},
	"internal/health/health.go.tpl":         {},
	"internal/health/readiness.go.tpl":      {},
	"internal/shutdown/shutdown.go.tpl":     {},
	"internal/storage/storage.go.tpl":       {},
}

// RenderRootTemplates recursively renders all root-level templates (excluding per-app templates) to the output root.
func RenderRootTemplates(data interface{}, templatesDir, outputBase string) error {
	return filepath.Walk(templatesDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil
		}
		if !strings.HasSuffix(info.Name(), ".tpl") {
			return nil
		}
		// Relative path from templatesDir
		relPath, err := filepath.Rel(templatesDir, path)
		if err != nil {
			return err
		}
		// Exclude per-app templates
		if _, ok := perAppTemplates[relPath]; ok {
			return nil
		}
		// Output path: strip .tpl, preserve subdirs
		outPath := relPath[:len(relPath)-4]
		output := filepath.Join(outputBase, outPath)
		if err := os.MkdirAll(filepath.Dir(output), 0750); err != nil {
			return err
		}

		// #nosec G304
		tplData, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		funcs := template.FuncMap{
			"ToLower":   strings.ToLower,
			"ToUpper":   strings.ToUpper,
			"SnakeCase": toSnakeCase,
			"KebabCase": toKebabCase,
			"Title":     titleFunc,
			"default":   defaultFunc,
			"add":       func(a, b int) int { return a + b },
		}
		tpl, err := template.New(info.Name()).Funcs(funcs).Parse(string(tplData))
		if err != nil {
			return err
		}
		var buf bytes.Buffer
		if err := tpl.Execute(&buf, data); err != nil {
			return err
		}
		return os.WriteFile(output, buf.Bytes(), 0600)
	})
}

// GenerateAll generates the full project structure (single-app or multi-app) based on the provided AppConfig.
// It renders all root-level templates and per-app directories as needed.
func GenerateAll(appConfig config.AppConfig, templatesDir, outputBase string) error {
	// Ensure output directory exists
	if err := os.MkdirAll(outputBase, 0750); err != nil {
		return err
	}
	if len(appConfig.App) > 1 {
		// Multi-app: render all root-level templates
		if err := RenderRootTemplates(appConfig, templatesDir, outputBase); err != nil {
			return err
		}
		// Generate each app as before
		for _, app := range appConfig.App {
			appPath := filepath.Join(outputBase, "apps", app.Name)
			if err := GenerateApp(app, templatesDir, appPath); err != nil {
				return err
			}
		}
		return nil
	}
	// Single app: render all root-level templates at the app root, but always pass AppConfig as context
	app := appConfig.App[0]
	appRoot := filepath.Join(outputBase, "app", app.Name)
	if err := os.MkdirAll(appRoot, 0750); err != nil {
		return err
	}
	// Wrap single app in AppConfig for template context
	singleAppConfig := config.AppConfig{App: []config.App{app}}
	if err := RenderRootTemplates(singleAppConfig, templatesDir, appRoot); err != nil {
		return err
	}
	return GenerateApp(app, templatesDir, appRoot)
}
