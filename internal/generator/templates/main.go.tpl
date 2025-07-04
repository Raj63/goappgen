package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	// Logger
	{{- if eq .Logger.Type "slog" }}
	"log/slog"
	{{- else if eq .Logger.Type "zap" }}
	"go.uber.org/zap"
	{{- else if eq .Logger.Type "zerolog" }}
	"github.com/rs/zerolog/log"
	{{- else }}
	"github.com/sirupsen/logrus"
	{{- end }}

	// Config
	{{- if eq .Config.Type "viper" }}
	"github.com/spf13/viper"
	{{- else if eq .Config.Type "envconfig" }}
	"github.com/kelseyhightower/envconfig"
	{{- end }}

	// HTTP Frameworks
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
	{{- else if eq .Transport.HTTPFramework "echo" }}
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	{{- if .Middlewares.RecordMetrics.Enabled }}
	"github.com/labstack/echo-contrib/prometheus"
	{{- end }}
	{{- else if eq .Transport.HTTPFramework "chi" }}
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/cors"
	"github.com/go-chi/httprate"
	"github.com/go-chi/chi/v5/middleware"
	{{- if .Middlewares.RecordMetrics.Enabled }}
	"github.com/pressly/chi-middleware-prometheus/prometheus"
	{{- end }}
	{{- else if eq .Transport.HTTPFramework "fiber" }}
	"github.com/gofiber/fiber/v2"
	{{- if .Middlewares.CORS.Enabled }}
	"github.com/gofiber/fiber/v2/middleware/cors"
	{{- end }}
	{{- if .Middlewares.RateLimiter.Enabled }}
	"github.com/gofiber/fiber/v2/middleware/limiter"
	{{- end }}
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	"github.com/gofiber/fiber/v2/middleware/recover"
	{{- end }}
	{{- if .Middlewares.RecordMetrics.Enabled }}
	"github.com/gofiber/fiber/v2/middleware/monitor"
	{{- end }}
	{{- end }}

	// gRPC
	{{- if .Transport.GRPC }}
	"google.golang.org/grpc"
	{{- if or .Middlewares.ExceptionHandler.Enabled .Middlewares.RecordMetrics.Enabled .Middlewares.RateLimiter.Enabled .Middlewares.Logging.Enabled .Middlewares.Tracing.Enabled .Middlewares.RequestID.Enabled }}
	"github.com/grpc-ecosystem/go-grpc-middleware"
	{{- end }}
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	"github.com/grpc-ecosystem/go-grpc-middleware/recovery"
	{{- end }}
	{{- if .Middlewares.RecordMetrics.Enabled }}
	"github.com/grpc-ecosystem/go-grpc-prometheus"
	{{- end }}
	{{- if .Middlewares.RateLimiter.Enabled }}
	"golang.org/x/time/rate"
	{{- end }}
	{{- if .Middlewares.Logging.Enabled }}
	"github.com/grpc-ecosystem/go-grpc-middleware/logging/logrus"
	"github.com/sirupsen/logrus"
	{{- end }}
	{{- if .Middlewares.Tracing.Enabled }}
	"github.com/grpc-ecosystem/go-grpc-middleware/tracing/opentracing"
	"github.com/opentracing/opentracing-go"
	{{- end }}
	{{- if .Middlewares.RequestID.Enabled }}
	"google.golang.org/grpc/metadata"
	{{- end }}
	{{- end }}

	// Database
	{{- if eq .Database.ORM "gorm" }}
	"gorm.io/gorm"
	"gorm.io/driver/postgres"
	{{- else if eq .Database.ORM "pgx" }}
	"github.com/jackc/pgx/v5"
	{{- end }}

	// Migrations
	{{- if .Database.Migrations }}
	"github.com/golang-migrate/migrate/v4"
	{{- end }}

	// Auth
	{{- if eq .Auth.Type "casbin" }}
	"github.com/casbin/casbin/v2"
	{{- else if eq .Auth.Type "jwt" }}
	"github.com/golang-jwt/jwt/v5"
	{{- end }}

	// Observability
	{{- if eq .Observability.Metrics "prometheus" }}
	"github.com/prometheus/client_golang/prometheus/promhttp"
	{{- end }}
	{{- if eq .Observability.Tracing "otel" }}
	"go.opentelemetry.io/otel"
	{{- end }}

	// Middlewares
	{{- if .Middlewares.RateLimiter.Enabled }}
	// TODO: Add rate limiter middleware here (e.g., github.com/ulule/limiter)
	{{- end }}
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	// TODO: Add global exception handler middleware
	{{- end }}
	{{- if .Middlewares.RecordMetrics.Enabled }}
	// TODO: Add Prometheus/OTel metrics middleware
	{{- end }}
	{{- if .Middlewares.Options.Enabled }}
	// TODO: Add automatic OPTIONS handler
	{{- end }}

	// Swaggo imports and setup
	{{- if .DevTools.Swagger }}
	// Swaggo/Swagger imports
	{{- if eq .Transport.HTTPFramework "gin" }}
	"github.com/swaggo/gin-swagger"
	swaggerFiles "github.com/swaggo/files"
	{{- end }}
	{{- if eq .Transport.HTTPFramework "echo" }}
	"github.com/swaggo/echo-swagger"
	swaggerFiles "github.com/swaggo/files"
	{{- end }}
	{{- if eq .Transport.HTTPFramework "chi" }}
	"github.com/swaggo/http-swagger"
	swaggerFiles "github.com/swaggo/files"
	{{- end }}
	{{- if eq .Transport.HTTPFramework "fiber" }}
	"github.com/gofiber/swagger"
	swaggerFiles "github.com/swaggo/files"
	{{- end }}
	{{- end }}
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// Logger setup
	{{- if eq .Logger.Type "slog" }}
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	logger.Info("slog is enabled")
	{{- else if eq .Logger.Type "zap" }}
	logger, _ := zap.NewProduction()
	defer logger.Sync()
	logger.Info("zap is enabled")
	{{- else if eq .Logger.Type "zerolog" }}
	// zerolog is global
    log.Print("zerolog is enabled")
	{{- else }}
	logger := logrus.New()
	logger.SetFormatter(&logrus.TextFormatter{})
	logger.SetLevel(logrus.InfoLevel)
	logger.Info("logrus is enabled")
	{{- end }}

	// Config setup
	{{- if eq .Config.Type "viper" }}
	viper.SetConfigName("config")
	viper.AddConfigPath(".")
	if err := viper.ReadInConfig(); err != nil {
		panic(fmt.Errorf("fatal config error: %w", err))
	}
	{{- else if eq .Config.Type "envconfig" }}
	var cfg Config
	if err := envconfig.Process("", &cfg); err != nil {
		panic(fmt.Errorf("fatal config error: %w", err))
	}
	{{- end }}

	// Database setup
	{{- if eq .Database.ORM "gorm" }}
	dsn := os.Getenv("DATABASE_DSN")
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	{{- else if eq .Database.ORM "pgx" }}
	dsn := os.Getenv("DATABASE_DSN")
	conn, err := pgx.Connect(ctx, dsn)
	if err != nil {
		panic("failed to connect database")
	}
	defer conn.Close(ctx)
	{{- end }}

	// Migrations
	{{- if .Database.Migrations }}
	// TODO: Run migrations using golang-migrate
	{{- end }}

	// Auth setup
	{{- if eq .Auth.Type "casbin" }}
	// TODO: Initialize Casbin enforcer
	{{- else if eq .Auth.Type "jwt" }}
	// TODO: Setup JWT middleware
	{{- end }}

	// Observability
	{{- if eq .Observability.Metrics "prometheus" }}
	go func() {
		http.Handle("/metrics", promhttp.Handler())
		http.ListenAndServe(":2112", nil)
	}()
	{{- end }}
	{{- if eq .Observability.Tracing "otel" }}
	// TODO: Setup OpenTelemetry tracing
	{{- end }}

	// HTTP server
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
		r.Run(":8080")
	}()
	{{- else if eq .Transport.HTTPFramework "echo" }}
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
		e.Start(":8080")
	}()
	{{- else if eq .Transport.HTTPFramework "chi" }}
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
	{{- else if eq .Transport.HTTPFramework "fiber" }}
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

	// gRPC server
	{{- if .Transport.GRPC }}
	var grpcServerOpts []grpc.ServerOption
	var unaryInterceptors []grpc.UnaryServerInterceptor
	// Exception handler (recovery interceptor)
	{{- if .Middlewares.ExceptionHandler.Enabled }}
	unaryInterceptors = append(unaryInterceptors, recovery.UnaryServerInterceptor())
	{{- end }}
	// Record metrics interceptor
	{{- if .Middlewares.RecordMetrics.Enabled }}
	unaryInterceptors = append(unaryInterceptors, grpc_prometheus.UnaryServerInterceptor)
	{{- end }}
	// Rate limiter interceptor (simple global limiter)
	{{- if .Middlewares.RateLimiter.Enabled }}
	limiter := rate.NewLimiter(rate.Limit({{ .Middlewares.RateLimiter.RequestsPerSecond }}), {{ .Middlewares.RateLimiter.Burst }})
	rateLimitInterceptor := func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		if !limiter.Allow() {
			return nil, status.Errorf(codes.ResourceExhausted, "rate limit exceeded")
		}
		return handler(ctx, req)
	}
	unaryInterceptors = append(unaryInterceptors, rateLimitInterceptor)
	{{- end }}
	// Logging interceptor
	{{- if .Middlewares.Logging.Enabled }}
	logrusEntry := logrus.NewEntry(logrus.New())
	unaryInterceptors = append(unaryInterceptors, logrus_unary.NewInterceptor(logrusEntry))
	{{- end }}
	// Tracing interceptor
	{{- if .Middlewares.Tracing.Enabled }}
	unaryInterceptors = append(unaryInterceptors, opentracing.UnaryServerInterceptor())
	{{- end }}
	// Request ID interceptor (custom example)
	{{- if .Middlewares.RequestID.Enabled }}
	requestIDInterceptor := func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		md, ok := metadata.FromIncomingContext(ctx)
		if ok {
			if ids := md.Get("x-request-id"); len(ids) > 0 {
				ctx = context.WithValue(ctx, "request-id", ids[0])
			}
		}
		return handler(ctx, req)
	}
	unaryInterceptors = append(unaryInterceptors, requestIDInterceptor)
	{{- end }}
	if len(unaryInterceptors) > 0 {
		grpcServerOpts = append(grpcServerOpts, grpc_middleware.WithUnaryServerChain(unaryInterceptors...))
	}
	grpcServer := grpc.NewServer(grpcServerOpts...)
	// Register services here
	// lis, _ := net.Listen("tcp", ":9090")
	// grpcServer.Serve(lis)
	go func() {
		// TODO: Register and start gRPC server
	}()
	{{- end }}

	// Graceful shutdown
	<-ctx.Done()
	fmt.Println("Shutting down...")
	// TODO: Add cleanup logic
}
