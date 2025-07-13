// Echo HTTP server setup
{{- if eq .Transport.HTTPFramework "echo" }}
	e := echo.New()
	// Exception handler (Recover)
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	e.Use(middleware.Recover())
	{{- end }}
	// CORS middleware
	{{- if .Middlewares.CORS.Enabled }}
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: {{ printf "%#v" .Middlewares.CORS.AllowOrigins }},
		AllowMethods: {{ printf "%#v" .Middlewares.CORS.AllowMethods }},
		AllowHeaders: {{ printf "%#v" .Middlewares.CORS.AllowHeaders }},
	}))
	{{- end }}
	// Rate limiter middleware
	{{- if .Middlewares.RateLimiter.Enabled }}
	e.Use(middleware.RateLimiter(middleware.NewRateLimiterMemoryStore({{ .Middlewares.RateLimiter.RequestsPerSecond }})))
	{{- end }}
	// Record metrics middleware
	{{- if .Middlewares.RecordMetrics.Enabled }}
	p := prometheus.NewPrometheus("echo", nil)
	p.Use(e)
	{{- end }}
	// OPTIONS handler (Echo handles automatically with CORS, but can add explicit route)
	{{- if .Middlewares.Options.Enabled }}
	e.OPTIONS("/*", func(c echo.Context) error {
		return c.NoContent(204)
	})
	{{- end }}

	// Swagger route
	{{- if .DevTools.Swagger }}
	e.GET("/swagger/*", echoSwagger.WrapHandler)
	{{- end }}
	// Example handler with Swagger comment
	// @Summary Health check
	// @Description Returns OK if the service is healthy
	// @Tags health
	// @Success 200 {object} map[string]string
	// @Router /healthz [get]
	e.GET("/healthz", func(c echo.Context) error { return c.JSON(200, map[string]string{"status": "ok"}) })
	// TODO: Add routes, middleware, etc.
	go func() {
		http.ListenAndServe(":8080", e)
	}()
{{- end }}
