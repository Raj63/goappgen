{{- if eq .Logger.Type "slog" }}
    "log/slog"
{{- if eq .Observability.Logs "loki"}}
	"github.com/grafana/loki-client-go/loki"
	slogloki "github.com/samber/slog-loki/v3"
{{- end }}
{{- end }}
