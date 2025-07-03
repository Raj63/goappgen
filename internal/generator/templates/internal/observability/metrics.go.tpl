package observability

import (
	{{- if eq .Observability.Metrics "prometheus" }}
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"net/http"
	{{- end }}
)

// InitMetrics sets up Prometheus metrics endpoint if enabled.
func InitMetrics() {
	{{- if eq .Observability.Metrics "prometheus" }}
	http.Handle("/metrics", promhttp.Handler())
	{{- end }}
} 