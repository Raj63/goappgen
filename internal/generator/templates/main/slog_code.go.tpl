{{- if eq .Logger.Type "slog" }}
    // Slog logger setup
    logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
    logger.Info("slog is enabled")
{{- end }}
