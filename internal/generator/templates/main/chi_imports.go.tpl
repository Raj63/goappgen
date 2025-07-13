{{- if eq .Transport.HTTPFramework "chi" }}
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/cors"
	"github.com/go-chi/httprate"
	"github.com/go-chi/chi/v5/middleware"
	{{- if .Middlewares.RecordMetrics.Enabled }}
	"github.com/pressly/chi-middleware-prometheus/prometheus"
	{{- end }}
{{- end }}
