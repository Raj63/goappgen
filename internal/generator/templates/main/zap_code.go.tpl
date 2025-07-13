{{- if eq .Logger.Type "zap" }}
    // Zap logger setup
    logger, _ := zap.NewProduction()
    defer logger.Sync()
    logger.Info("zap is enabled")
{{- end }}
