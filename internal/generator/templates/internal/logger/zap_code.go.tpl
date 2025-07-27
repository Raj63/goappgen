{{- if eq .Logger.Type "zap" }}
func InitializeLogger() *zap.Logger {
    // Zap logger setup
    logger, _ := zap.NewProduction()
    defer logger.Sync()
    logger.Info("zap is enabled")
    {{- if eq .Observability.Logs "loki"}}
    // Hook loki if enabled
    logger = initLokiLogger(logger)
    {{- end }}
    return logger
}

{{- if eq .Observability.Logs "loki"}}

// initLokiLogger adds a Loki hook to the logger if enabled and returns the logger instance.
func initLokiLogger(logger *zap.Logger) *zap.Logger {
    loki := zaploki.New(context.Background(), zaploki.Config{
        Url:          "http://localhost:3100",
        BatchMaxSize: 1000,
        BatchMaxWait: 10 * time.Second,
        Labels:       map[string]string{"app": "ginapp"},
    })
    logger = logger.WithOptions(zap.Hooks(loki.Hook))

	return logger
}
{{- end }}
{{- end }}
