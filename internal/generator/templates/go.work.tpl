go 1.23

use (
{{- range .App }}
	./{{ .Name }}
{{- end }}
) 