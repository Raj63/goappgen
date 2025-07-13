{{- if eq .Auth.Type "casbin" }}
	"github.com/casbin/casbin/v2"
{{- else if eq .Auth.Type "jwt" }}
	"github.com/golang-jwt/jwt/v5"
{{- end }}
