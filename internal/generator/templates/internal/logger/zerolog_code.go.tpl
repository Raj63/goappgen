{{- if or (eq .Logger.Type "zerolog") (eq .Logger.Type "") }}
func InitializeLogger() zerolog.Logger {
    // Zerolog logger setup
    log.Print("zerolog is enabled")
    {{- if eq .Observability.Logs "loki"}}
    // Hook loki if enabled
    initLokiLogger()
    {{- end }}
    return log.Logger
}
{{- if eq .Observability.Logs "loki"}}

// initLokiLogger adds a Loki hook to the logger if enabled and returns the logger instance.
func initLokiLogger()  {
	hook := zerologlokipublisher.NewHook(zerologlokipublisher.LokiConfig{
		PushIntveralSeconds: 10,
		MaxBatchSize:        500,
		LokiEndpoint:        "http://localhost:3100",
		ServiceName:         "goappgen",
	})
	log.Logger = log.Hook(hook)
}
{{- end }}
{{- end }}
