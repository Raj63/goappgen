// Fiber HTTP server setup
{{- if eq .Transport.HTTPFramework "fiber" }}
	app := fiber.New()
	// Exception handler (Recover)
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	app.Use(recover.New())
	{{- end }}
	// CORS middleware
	{{- if .Middlewares.CORS.Enabled }}
	app.Use(cors.New(cors.Config{
		AllowOrigins: "{{ join .Middlewares.CORS.AllowOrigins "," }}",
		AllowMethods: "{{ join .Middlewares.CORS.AllowMethods "," }}",
		AllowHeaders: "{{ join .Middlewares.CORS.AllowHeaders "," }}",
	}))
	{{- end }}
	// Rate limiter middleware
	{{- if .Middlewares.RateLimiter.Enabled }}
	app.Use(limiter.New(limiter.Config{
		Max: {{ .Middlewares.RateLimiter.Burst }},
		Expiration: 60 * time.Second,
	}))
	{{- end }}
	// Record metrics middleware
	{{- if .Middlewares.RecordMetrics.Enabled }}
	app.Use(monitor.New())
	{{- end }}
	// OPTIONS handler
	{{- if .Middlewares.Options.Enabled }}
	app.Options("/*", func(c *fiber.Ctx) error {
		return c.SendStatus(204)
	})
	{{- end }}

	// Swagger route
	{{- if .DevTools.Swagger }}
	app.Get("/swagger/*", swagger.HandlerDefault)
	{{- end }}
	// Example handler with Swagger comment
	// @Summary Health check
	// @Description Returns OK if the service is healthy
	// @Tags health
	// @Success 200 {object} map[string]string
	// @Router /healthz [get]
	app.Get("/healthz", func(c *fiber.Ctx) error { return c.JSON(fiber.Map{"status": "ok"}) })
	// TODO: Add routes, middleware, etc.
	go func() {
		app.Listen(":8080")
	}()
{{- end }}
