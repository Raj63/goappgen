package logger

{{- if eq .Logger.Type "logrus" }}
import (
	// Logger imports
	{{ include "logrus_imports.go.tpl" }}
)

{{ include "logrus_code.go.tpl" }}
{{- else if eq .Logger.Type "zap" }}
import (
	// Logger imports
	{{ include "zap_imports.go.tpl" }}
)

{{ include "zap_code.go.tpl" }}
{{- else if eq .Logger.Type "zerolog" }}
import (
	// Logger imports
	{{ include "zerolog_imports.go.tpl" }}
)

{{ include "zerolog_code.go.tpl" }}
{{- else if eq .Logger.Type "slog" }}
import (
	// Logger imports
	{{ include "slog_imports.go.tpl" }}
)

{{ include "slog_code.go.tpl" }}
{{- end }}
