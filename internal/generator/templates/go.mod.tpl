module {{ .Name }}

go 1.24.4

require (
	github.com/sirupsen/logrus v1.9.3
	github.com/spf13/viper v1.17.0
	{{- if .DevTools.Swagger }}
	github.com/swaggo/swag v1.16.3
	{{- if eq .Transport.HTTPFramework "gin" }}
	github.com/swaggo/gin-swagger v1.6.0
	{{- end }}
	{{- if eq .Transport.HTTPFramework "echo" }}
	github.com/swaggo/echo-swagger v1.3.0
	{{- end }}
	{{- if eq .Transport.HTTPFramework "chi" }}
	github.com/swaggo/http-swagger v1.2.0
	{{- end }}
	{{- if eq .Transport.HTTPFramework "fiber" }}
	github.com/gofiber/swagger v2.0.0
	{{- end }}
	{{- end }}
)
