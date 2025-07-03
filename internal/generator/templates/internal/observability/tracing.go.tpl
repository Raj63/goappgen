package observability

import (
	{{- if eq .Observability.Tracing "otel" }}
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/sdk/trace"
	"context"
	{{- end }}
)

// InitTracing sets up OpenTelemetry tracing if enabled.
func InitTracing(ctx context.Context) error {
	{{- if eq .Observability.Tracing "otel" }}
	tp := trace.NewTracerProvider()
	otel.SetTracerProvider(tp)
	// TODO: Configure exporter, resources, etc.
	return nil
	{{- else }}
	return nil
	{{- end }}
}
