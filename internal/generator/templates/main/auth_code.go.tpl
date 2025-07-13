{{- if eq .Auth.Type "casbin" }}
// TODO: Initialize Casbin enforcer
{{- else if eq .Auth.Type "jwt" }}
// TODO: Setup JWT middleware
{{- end }}
