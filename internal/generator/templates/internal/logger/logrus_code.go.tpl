{{- if eq .Logger.Type "logrus" }}
// InitializeLogger initialize an instance of logrus logger and returns
func InitializeLogger() *logrus.Logger {
    // Logrus logger setup
    logger := logrus.New()
    logger.SetFormatter(&logrus.TextFormatter{})
    logger.SetLevel(logrus.InfoLevel)
    logger.Info("logrus is enabled")
    {{- if eq .Observability.Logs "loki"}}
    // Hook loki if enabled
    logger = initLokiLogger(logger)
    {{- end }}
    return logger
}
{{- if eq .Observability.Logs "loki"}}

// initLokiLogger adds a Loki hook to the logger if enabled and returns the logger instance.
func initLokiLogger(logger *logrus.Logger) *logrus.Logger {
    // Configure the Loki hook
    opts := lokirus.NewLokiHookOptions().
        // Grafana doesn't have a "panic" level, but it does have a "critical" level
        // https://grafana.com/docs/grafana/latest/explore/logs-integration/
        WithLevelMap(lokirus.LevelMap{logrus.PanicLevel: "critical"}).
        WithFormatter(&logrus.JSONFormatter{}).
        WithStaticLabels(lokirus.Labels{
            "app":         "example",
            "environment": "development",
        }).
        WithBasicAuth("admin", "secretpassword") // Optional

    hook := lokirus.NewLokiHookWithOpts(
        "http://localhost:3100",
        opts,
        logrus.InfoLevel,
        logrus.WarnLevel,
        logrus.ErrorLevel,
        logrus.FatalLevel)

    logger.AddHook(hook)

	return logger
}
{{- end }}
{{- end }}
