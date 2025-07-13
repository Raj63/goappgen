{{- if eq .Config.Type "viper" }}
	"github.com/spf13/viper"
{{- else if eq .Config.Type "envconfig" }}
	"github.com/kelseyhightower/envconfig"
{{- end }}
