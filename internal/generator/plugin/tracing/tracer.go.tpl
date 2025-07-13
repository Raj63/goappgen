package tracing

import (
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/sdk/trace"
)

func InitTracer(serviceName string) {
	tp := trace.NewTracerProvider()
	otel.SetTracerProvider(tp)
}
