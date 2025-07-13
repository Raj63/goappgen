// Gin HTTP server setup
{{- if eq .Transport.HTTPFramework "gin" }}
	r := gin.New()
	// Exception handler (Recovery)
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	r.Use(gin.Recovery())
	{{- else }}
	r.Use()
	{{- end }}
	// CORS middleware
	{{- if .Middlewares.CORS.Enabled }}
	r.Use(cors.New(cors.Config{
		AllowOrigins: {{ printf "%#v" .Middlewares.CORS.AllowOrigins }},
		AllowMethods: {{ printf "%#v" .Middlewares.CORS.AllowMethods }},
		AllowHeaders: {{ printf "%#v" .Middlewares.CORS.AllowHeaders }},
	}))
	{{- end }}
	// Rate limiter middleware (global, simple example)
	{{- if .Middlewares.RateLimiter.Enabled }}
	limiter := rate.NewLimiter(rate.Limit({{ .Middlewares.RateLimiter.RequestsPerSecond }}), {{ .Middlewares.RateLimiter.Burst }})
	r.Use(func(c *gin.Context) {
		if !limiter.Allow() {
			c.AbortWithStatusJSON(429, gin.H{"error": "rate limit exceeded"})
			return
		}
		c.Next()
	})
	{{- end }}
	// Record metrics middleware
	{{- if .Middlewares.RecordMetrics.Enabled }}
	prom := ginprometheus.NewPrometheus("gin")
	prom.Use(r)
	{{- end }}
	// OPTIONS handler (Gin handles automatically with CORS, but can add explicit route)
	{{- if .Middlewares.Options.Enabled }}
	r.OPTIONS("/*path", func(c *gin.Context) {
		c.Status(204)
	})
	{{- end }}

	// Swagger route
	{{- if .DevTools.Swagger }}
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	{{- end }}
	// Example handler with Swagger comment
	// @Summary Health check
	// @Description Returns OK if the service is healthy
	// @Tags health
	// @Success 200 {object} map[string]string
	// @Router /healthz [get]
	r.GET("/healthz", func(c *gin.Context) { c.JSON(200, gin.H{"status": "ok"}) })
	// TODO: Add routes, middleware, etc.
	go func() {
		http.ListenAndServe(":8080", r)
	}()
{{- end }}
