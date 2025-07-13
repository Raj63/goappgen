{{- if eq .Logger.Type "logrus" }}
	// Logrus logger setup
    logger := logrus.New()
    logger.SetFormatter(&logrus.TextFormatter{})
    logger.SetLevel(logrus.InfoLevel)
    logger.Info("logrus is enabled")
{{- end }}
