package logger

import (
	{{- if eq .Logger.Type "logrus" }}
	"github.com/sirupsen/logrus"
	"github.com/grafana/loki-client-go/lokilogrus"
	{{- else if eq .Logger.Type "zap" }}
	"go.uber.org/zap"
	"github.com/grafana/loki-client-go/lokizap"
	{{- else if eq .Logger.Type "zerolog" }}
	"github.com/rs/zerolog"
	"github.com/grafana/loki-client-go/lokizerolog"
	{{- end }}
)

// InitLokiLogger adds a Loki hook to the logger if enabled.
func InitLokiLogger(logger interface{}) interface{} {
	{{- if eq .Logger.Type "logrus" }}
	if l, ok := logger.(*logrus.Logger); ok {
		l.AddHook(lokilogrus.NewHook("http://localhost:3100/loki/api/v1/push", "goappgen"))
	}
	return logger
	{{- else if eq .Logger.Type "zap" }}
	if l, ok := logger.(*zap.Logger); ok {
		l = l.WithOptions(zap.Hooks(lokizap.NewHook("http://localhost:3100/loki/api/v1/push", "goappgen")))
		return l
	}
	return logger
	{{- else if eq .Logger.Type "zerolog" }}
	if l, ok := logger.(zerolog.Logger); ok {
		l = l.Hook(lokizerolog.NewHook("http://localhost:3100/loki/api/v1/push", "goappgen"))
		return l
	}
	return logger
	{{- else }}
	return logger
	{{- end }}
}
