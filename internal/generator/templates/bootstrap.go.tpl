package main

import (
{{- if .Observability.Tracing.Enabled }}
	"{{ .Name }}/internal/tracing"
{{- end }}
{{- if .Observability.Metrics.Enabled }}
	"{{ .Name }}/internal/metrics"
{{- end }}
)

func initPlugins(appName string) {
{{- if .Observability.Tracing.Enabled }}
	tracing.InitTracer(appName)
{{- end }}
{{- if .Observability.Metrics.Enabled }}
	metrics.Register()
{{- end }}
}
