{{- if eq .Logger.Type "slog" }}
func InitializeLogger() *slog.Logger {
    {{- if eq .Observability.Logs "loki"}}
    // create logger and hook loki if enabled
    logger := initLokiLogger(logger)
    {{- else }}
    // Slog logger setup
    logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
    logger.Info("slog is enabled")
    {{- end }}
    return logger
}
{{- if eq .Observability.Logs "loki"}}

// InitLokiLogger adds a Loki hook to the logger if enabled and returns the logger instance.
func initLokiLogger() *slog.Logger {
	// setup loki client
	config, _ := loki.NewDefaultConfig("http://localhost:3100/loki/api/v1/push")
	config.TenantID = "tenant1"
	client, _ := loki.New(config)

	logger := slog.New(slogloki.Option{Level: slog.LevelDebug, Client: client}.NewLokiHandler())
	logger = logger.
		With("app", "goappgen").
		With("environment", "dev").
		With("release", "v1.0.0")

	return logger
}
{{- end }}
{{- end }}
