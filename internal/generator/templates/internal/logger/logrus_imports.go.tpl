
{{- if eq .Logger.Type "logrus" }}
    "github.com/sirupsen/logrus"
{{- if eq .Observability.Logs "loki"}}
    "github.com/culionbear/lokirus"
	"github.com/sirupsen/logrus"
{{- end }}
{{- end }}
