{{- if eq .Transport.HTTPFramework "gin" }}
	"github.com/gin-gonic/gin"
	{{- if .Middlewares.CORS.Enabled }}
	"github.com/gin-contrib/cors"
	{{- end }}
	{{- if .Middlewares.RecordMetrics.Enabled }}
	"github.com/zsais/go-gin-prometheus"
	{{- end }}
	{{- if .Middlewares.RateLimiter.Enabled }}
	"golang.org/x/time/rate"
	{{- end }}
{{- end }}
