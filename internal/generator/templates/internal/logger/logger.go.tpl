package logger

import (
	"os"
	{{- if eq .Logger.Type "slog" }}
	"log/slog"
	{{- else if eq .Logger.Type "zap" }}
	"go.uber.org/zap"
	{{- else if eq .Logger.Type "zerolog" }}
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	{{- else }}
	"github.com/sirupsen/logrus"
	{{- end }}
)

// InitLogger initializes and returns the configured logger.
func InitLogger() interface{} {
	{{- if eq .Logger.Type "slog" }}
	return slog.New(slog.NewTextHandler(os.Stdout, nil))
	{{- else if eq .Logger.Type "zap" }}
	logger, _ := zap.NewProduction()
	return logger
	{{- else if eq .Logger.Type "zerolog" }}
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	return log.Logger
	{{- else }}
	logger := logrus.New()
	logger.SetFormatter(&logrus.TextFormatter{})
	logger.SetLevel(logrus.InfoLevel)
	return logger
	{{- end }}
}
