{{- if eq .Logger.Type "zerolog" }}
    // Zerolog logger setup
    log.Print("zerolog is enabled")
{{- end }}
