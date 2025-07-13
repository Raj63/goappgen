package generator

import (
	"embed"
)

// TemplatesFS embeds all generator templates for use by the generator.
//
//go:embed templates/*.tpl templates/**/*.tpl templates/internal/**/*.tpl plugin/casbin/*.tpl plugin/tracing/*.tpl plugin/metrics/*.tpl plugin/jwt/*.tpl
var TemplatesFS embed.FS
