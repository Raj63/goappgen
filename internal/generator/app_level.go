package generator

import (
	"bytes"
	"embed"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator/renderer"
)

// ensureDir creates a directory and wraps errors with feature/app context.
func ensureDir(path, feature, appName string) error {
	if err := os.MkdirAll(path, 0700); err != nil {
		return fmt.Errorf("failed to create %s directory for app %s: %w", feature, appName, err)
	}
	return nil
}

// renderTpl wraps renderer.RenderTemplate with error context.
func renderTpl(app config.App, fs embed.FS, outputPath, tpl string) error {
	tplPath := filepath.Join("templates", tpl)
	tplData, err := fs.ReadFile(tplPath)
	if err != nil {
		return fmt.Errorf("failed to read template %s: %w", tplPath, err)
	}

	dir := filepath.Dir(tpl)
	funcs := template.FuncMap{
		"ToLower":   strings.ToLower,
		"ToUpper":   strings.ToUpper,
		"SnakeCase": renderer.ToSnakeCase,
		"KebabCase": renderer.ToKebabCase,
		"Title":     renderer.TitleFunc,
		"default":   renderer.DefaultFunc,
		"add":       func(a, b int) int { return a + b },
		"join":      strings.Join,
		// Add the include function for nested templates:
		"include": func(name string) (string, error) {
			return renderModularTemplate(app, fs, dir, name)
		},
	}

	tplObj, err := template.New(filepath.Base(tpl)).Funcs(funcs).Parse(string(tplData))
	if err != nil {
		return fmt.Errorf("failed to parse template %s: %w", tpl, err)
	}

	var buf bytes.Buffer
	if err := tplObj.Execute(&buf, app); err != nil {
		return fmt.Errorf("failed to execute template %s: %w", tpl, err)
	}

	outputPath = filepath.Join(outputPath, dir)
	// Write the output file as before...
	outputFile := filepath.Join(outputPath, strings.TrimSuffix(filepath.Base(tpl), ".tpl"))
	if err := os.WriteFile(outputFile, buf.Bytes(), 0600); err != nil {
		return fmt.Errorf("failed to write output file %s: %w", outputFile, err)
	}

	return nil
}

func renderCommonAppTemplates(app config.App, appPath string) error {
	if err := os.MkdirAll(appPath, 0750); err != nil {
		return err
	}
	commonAppTpls := []string{
		"Dockerfile.tpl",
		"go.mod.tpl",
		"Makefile.app.tpl",
		"air.toml.tpl",
		"docker-compose.app.yml.tpl",
	}
	for _, tpl := range commonAppTpls {
		if err := renderTpl(app, TemplatesFS, appPath, tpl); err != nil {
			return err
		}
	}
	if err := renderTemplateWithModularSupport(app, appPath, "main.go.tpl"); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "bootstrap.go.tpl"); err != nil {
		return err
	}
	return nil
}

func renderConfigTemplates(app config.App, appPath string) error {
	if app.Config.Type == "" {
		return nil
	}
	confDir := filepath.Join(appPath, "configs")
	if err := ensureDir(confDir, "configs", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "configs/config.go.tpl"); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "configs/config.yaml.tpl"); err != nil {
		return err
	}
	return nil
}

func renderDatabaseTemplates(app config.App, appPath string) error {
	if app.Database.Type == "" {
		return nil
	}
	dbDir := filepath.Join(appPath, "internal", "db")
	if err := ensureDir(dbDir, "db", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/db/init.go.tpl"); err != nil {
		return err
	}
	if app.Database.Migrations {
		if err := renderTpl(app, TemplatesFS, appPath, "internal/db/migrations.go.tpl"); err != nil {
			return err
		}
		if err := renderTpl(app, TemplatesFS, appPath, "internal/db/seeding.go.tpl"); err != nil {
			return err
		}
	}
	return nil
}

func renderAuthTemplates(app config.App, appPath string) error {
	if app.Auth.Type == "" {
		return nil
	}
	authDir := filepath.Join(appPath, "internal", "auth")
	if err := ensureDir(authDir, "auth", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/auth/auth.go.tpl"); err != nil {
		return err
	}
	return nil
}

func renderHealthTemplates(app config.App, appPath string) error {
	healthDir := filepath.Join(appPath, "internal", "health")
	if err := ensureDir(healthDir, "health", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/health/health.go.tpl"); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/health/readiness.go.tpl"); err != nil {
		return err
	}
	return nil
}

func renderShutdownTemplates(app config.App, appPath string) error {
	shutdownDir := filepath.Join(appPath, "internal", "shutdown")
	if err := ensureDir(shutdownDir, "shutdown", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/shutdown/shutdown.go.tpl"); err != nil {
		return err
	}
	return nil
}

func renderLoggerTemplates(app config.App, appPath string) error {
	if app.Logger.Type != "logrus" && app.Logger.Type != "zap" && app.Logger.Type != "zerolog" {
		return nil
	}
	loggerDir := filepath.Join(appPath, "internal", "logger")
	if err := ensureDir(loggerDir, "loki logger", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/logger/logger.go.tpl"); err != nil {
		return err
	}
	return nil
}

func renderStorageTemplates(app config.App, appPath string) error {
	if app.Storage.Type != "s3" && app.Storage.Type != "minio" {
		return nil
	}
	storageDir := filepath.Join(appPath, "internal", "storage")
	if err := ensureDir(storageDir, "storage", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "internal/storage/storage.go.tpl"); err != nil {
		return err
	}
	return nil
}

func renderK8sTemplates(app config.App, appPath string) error {
	if !app.DevTools.Kubernetes {
		return nil
	}
	k8sDir := filepath.Join(appPath, "k8s")
	if err := ensureDir(k8sDir, "k8s", app.Name); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "k8s/deployment.yaml.tpl"); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "k8s/service.yaml.tpl"); err != nil {
		return err
	}
	if err := renderTpl(app, TemplatesFS, appPath, "k8s/ingress.yaml.tpl"); err != nil {
		return err
	}
	return nil
}

// GenerateApp generates a Go application scaffold based on the provided App configuration.
// It uses templates from templatesDir and writes the output to outputBase/app.Name.
// TODO: Refactor GenerateApp to reduce cyclomatic complexity (gocyclo)
func GenerateApp(app config.App, appPath string) error {
	if err := renderCommonAppTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderConfigTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderDatabaseTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderAuthTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderHealthTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderShutdownTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderLoggerTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderStorageTemplates(app, appPath); err != nil {
		return err
	}
	if err := renderK8sTemplates(app, appPath); err != nil {
		return err
	}
	return nil
}

// renderModularTemplate renders a modular template and returns its content
func renderModularTemplate(app config.App, templatesFS embed.FS, dir, templateName string) (string, error) {
	var embedPath string
	if dir == "" || dir == "." {
		fmt.Println("current dir")
	} else {
		embedPath = filepath.Join("templates", dir)
	}
	embedPath = filepath.Join(embedPath, templateName)
	tplData, err := templatesFS.ReadFile(embedPath)
	if err != nil {
		return "", err
	}

	funcs := template.FuncMap{
		"ToLower":   strings.ToLower,
		"ToUpper":   strings.ToUpper,
		"SnakeCase": renderer.ToSnakeCase,
		"KebabCase": renderer.ToKebabCase,
		"Title":     renderer.TitleFunc,
		"default":   renderer.DefaultFunc,
		"add":       func(a, b int) int { return a + b },
		"join":      strings.Join,
	}

	tpl, err := template.New(filepath.Base(templateName)).Funcs(funcs).Parse(string(tplData))
	if err != nil {
		return "", err
	}

	var buf bytes.Buffer
	if err := tpl.Execute(&buf, app); err != nil {
		return "", err
	}

	return buf.String(), nil
}

// renderTemplateWithModularSupport renders a template with support for modular includes
func renderTemplateWithModularSupport(app config.App, appPath, tplName string) error {
	embedPath := filepath.Join("templates", tplName)
	tplData, err := TemplatesFS.ReadFile(embedPath)
	if err != nil {
		return err
	}

	funcs := template.FuncMap{
		"ToLower":   strings.ToLower,
		"ToUpper":   strings.ToUpper,
		"SnakeCase": renderer.ToSnakeCase,
		"KebabCase": renderer.ToKebabCase,
		"Title":     renderer.TitleFunc,
		"default":   renderer.DefaultFunc,
		"add":       func(a, b int) int { return a + b },
		"join":      strings.Join,
		"include": func(name string) (string, error) {
			return renderModularTemplate(app, TemplatesFS, "main", name)
		},
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
