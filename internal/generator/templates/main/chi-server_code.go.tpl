// Chi HTTP server setup
{{- if eq .Transport.HTTPFramework "chi" }}
	r := chi.NewRouter()
	// Exception handler (Recoverer)
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	r.Use(middleware.Recoverer)
	{{- end }}
	// CORS middleware
	{{- if .Middlewares.CORS.Enabled }}
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins: {{ printf "%#v" .Middlewares.CORS.AllowOrigins }},
		AllowedMethods: {{ printf "%#v" .Middlewares.CORS.AllowMethods }},
		AllowedHeaders: {{ printf "%#v" .Middlewares.CORS.AllowHeaders }},
	}))
	{{- end }}
	// Rate limiter middleware
	{{- if .Middlewares.RateLimiter.Enabled }}
	r.Use(httprate.LimitByIP({{ .Middlewares.RateLimiter.RequestsPerSecond }}, {{ .Middlewares.RateLimiter.Burst }}))
	{{- end }}
	// Record metrics middleware
	{{- if .Middlewares.RecordMetrics.Enabled }}
	prom := prometheus.New("chi")
	r.Use(prom.Handler)
	{{- end }}
	// OPTIONS handler
	{{- if .Middlewares.Options.Enabled }}
	r.Options("/*", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(204)
	})
	{{- end }}

	// Swagger route
	{{- if .DevTools.Swagger }}
	r.Get("/swagger/*", httpSwagger.WrapHandler)
	{{- end }}
	// Example handler with Swagger comment
	// @Summary Health check
	// @Description Returns OK if the service is healthy
	// @Tags health
	// @Success 200 {object} map[string]string
	// @Router /healthz [get]
	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok")) })
	// TODO: Add routes, middleware, etc.
	go func() {
		http.ListenAndServe(":8080", r)
	}()
{{- end }}
