{{- if eq .Logger.Type "zap" }}
    "go.uber.org/zap"
{{- if eq .Observability.Logs "loki"}}
    "context"
	"time"

	zaploki "github.com/paul-milne/zap-loki"
{{- end }}
{{- end }}
