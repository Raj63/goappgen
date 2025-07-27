// Package renderer provides the rendering funcs for templates.
package renderer

import (
	"bytes"
	"embed"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"unicode"

	"github.com/Raj63/goappgen/internal/config"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

// RenderTemplate renders a template for the given app using the embedded filesystem.
func RenderTemplate(app config.App, templatesFS embed.FS, targetPath, tplName string) error {
	// Use embedded templates
	embedPath := filepath.Join("templates", tplName)
	if strings.HasPrefix(tplName, "plugin/") {
		embedPath = tplName
	}
	tplData, err := templatesFS.ReadFile(embedPath)
	if err != nil {
		return err
	}

	funcs := template.FuncMap{
		"ToLower":   strings.ToLower,
		"ToUpper":   strings.ToUpper,
		"SnakeCase": ToSnakeCase,
		"KebabCase": ToKebabCase,
		"Title":     TitleFunc,
		"default":   DefaultFunc,
		"add":       func(a, b int) int { return a + b },
		"join":      strings.Join,
	}

	tpl, err := template.New(filepath.Base(tplName)).Funcs(funcs).Parse(string(tplData))
	if err != nil {
		return err
	}

	var buf bytes.Buffer
	if err := tpl.Execute(&buf, app); err != nil {
		return err
	}
	if strings.HasPrefix(tplName, "k8s") {
		tplName = filepath.Base(tplName)
	}
	if strings.HasPrefix(tplName, "plugin/") {
		tplName = filepath.Base(tplName)
	}

	output := filepath.Join(targetPath, tplName[:len(tplName)-4])
	if err := os.MkdirAll(filepath.Dir(output), 0750); err != nil {
		return err
	}
	return os.WriteFile(output, buf.Bytes(), 0600)
}

// ToSnakeCase converts CamelCase to snake_case.
func ToSnakeCase(str string) string {
	var result []rune
	for i, r := range str {
		if unicode.IsUpper(r) && i > 0 {
			result = append(result, '_')
		}
		result = append(result, unicode.ToLower(r))
	}
	return string(result)
}

// ToKebabCase converts CamelCase to kebab-case.
func ToKebabCase(str string) string {
	var result []rune
	for i, r := range str {
		if unicode.IsUpper(r) && i > 0 {
			result = append(result, '-')
		}
		result = append(result, unicode.ToLower(r))
	}
	return string(result)
}

// DefaultFunc returns the default value if val is nil or empty.
func DefaultFunc(def, val interface{}) interface{} {
	if val == nil {
		return def
	}
	v, ok := val.(string)
	if ok && v == "" {
		return def
	}
	return val
}

// TitleFunc returns the title-cased version of the input string.
func TitleFunc(s string) string {
	return cases.Title(language.Und).String(s)
}

// RenderRootTemplate renders a template using AppConfig data for root-level templates
func RenderRootTemplate(appConfig config.AppConfig, templatesFS embed.FS, outputBase, tplName string) error {
	// Use embedded templates
	embedPath := filepath.Join("templates", tplName)
	if strings.HasPrefix(tplName, "internal/plugin/") {
		embedPath = strings.TrimPrefix(tplName, "internal/")
	}
	tplData, err := templatesFS.ReadFile(embedPath)
	if err != nil {
		return err
	}

	funcs := template.FuncMap{
		"ToLower":   strings.ToLower,
		"ToUpper":   strings.ToUpper,
		"SnakeCase": ToSnakeCase,
		"KebabCase": ToKebabCase,
		"Title":     TitleFunc,
		"default":   DefaultFunc,
		"add":       func(a, b int) int { return a + b },
		"join":      strings.Join,
	}

	tpl, err := template.New(filepath.Base(tplName)).Funcs(funcs).Parse(string(tplData))
	if err != nil {
		return err
	}

	var buf bytes.Buffer
	if err := tpl.Execute(&buf, appConfig); err != nil {
		return err
	}

	output := filepath.Join(outputBase, tplName[:len(tplName)-4])
	if err := os.MkdirAll(filepath.Dir(output), 0750); err != nil {
		return err
	}
	return os.WriteFile(output, buf.Bytes(), 0600)
}
