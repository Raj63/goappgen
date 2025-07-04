go 1.24.4

use (
{{- range .App }}
	./apps/{{ .Name }}
{{- end }}
)
