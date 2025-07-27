{{- if or (eq .Logger.Type "zerolog") (eq .Logger.Type "") }}
    "github.com/rs/zerolog/log"
{{- if eq .Observability.Logs "loki"}}
    zerologlokipublisher "github.com/coffeemakingtoaster/zerolog-loki-publisher"
	"github.com/rs/zerolog/log"
{{- end }}
{{- end }}
