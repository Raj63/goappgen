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
	{{- else if eq .Transport.HTTPFramework "echo" }}
	"github.com/labstack/echo/v4"
	{{- else if eq .Transport.HTTPFramework "chi" }}
	"github.com/go-chi/chi/v5"
	{{- end }}

	// gRPC
	{{- if .Transport.GRPC }}
	"google.golang.org/grpc"
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
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// Logger setup
	{{- if eq .Logger.Type "slog" }}
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	{{- else if eq .Logger.Type "zap" }}
	logger, _ := zap.NewProduction()
	defer logger.Sync()
	{{- else if eq .Logger.Type "zerolog" }}
	// zerolog is global
	{{- else }}
	logger := logrus.New()
	logger.SetFormatter(&logrus.TextFormatter{})
	logger.SetLevel(logrus.InfoLevel)
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
	r := gin.Default()
	r.GET("/healthz", func(c *gin.Context) { c.JSON(200, gin.H{"status": "ok"}) })
	// TODO: Add routes, middleware, etc.
	go func() {
		r.Run(":8080")
	}()
	{{- else if eq .Transport.HTTPFramework "echo" }}
	e := echo.New()
	e.GET("/healthz", func(c echo.Context) error { return c.JSON(200, map[string]string{"status": "ok"}) })
	// TODO: Add routes, middleware, etc.
	go func() {
		e.Start(":8080")
	}()
	{{- else if eq .Transport.HTTPFramework "chi" }}
	r := chi.NewRouter()
	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok")) })
	// TODO: Add routes, middleware, etc.
	go func() {
		http.ListenAndServe(":8080", r)
	}()
	{{- end }}

	// gRPC server
	{{- if .Transport.GRPC }}
	go func() {
		// TODO: Register and start gRPC server
		grpcServer := grpc.NewServer()
		// Register services here
		// lis, _ := net.Listen("tcp", ":9090")
		// grpcServer.Serve(lis)
	}()
	{{- end }}

	// Graceful shutdown
	<-ctx.Done()
	fmt.Println("Shutting down...")
	// TODO: Add cleanup logic
}
