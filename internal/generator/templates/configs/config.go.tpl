package config

import (
	{{- if eq .Config.Type "viper" }}
	"github.com/spf13/viper"
	{{- else if eq .Config.Type "envconfig" }}
	"github.com/kelseyhightower/envconfig"
	{{- end }}
)

type Config struct {
	// HTTP server port
	HTTPPort string `mapstructure:"http_port" env:"HTTP_PORT"`
	// gRPC server port
	GRPCPort string `mapstructure:"grpc_port" env:"GRPC_PORT"`
	// Database DSN (Postgres, MySQL, SQLite, etc.)
	DatabaseDSN string `mapstructure:"database_dsn" env:"DATABASE_DSN"`
	// MongoDB URI (if using MongoDB)
	MongoURI string `mapstructure:"mongo_uri" env:"MONGO_URI"`
	// Connection Pooling
	DBMaxOpenConns    int    `mapstructure:"db_max_open_conns" env:"DB_MAX_OPEN_CONNS"`
	DBMaxIdleConns    int    `mapstructure:"db_max_idle_conns" env:"DB_MAX_IDLE_CONNS"`
	DBConnMaxLifetime string `mapstructure:"db_conn_max_lifetime" env:"DB_CONN_MAX_LIFETIME"`
	// JWT Auth secret
	JWTSecret string `mapstructure:"jwt_secret" env:"JWT_SECRET"`
	// Observability metrics port
	MetricsPort string `mapstructure:"metrics_port" env:"METRICS_PORT"`
}

// LoadConfig loads the application configuration using the selected provider.
func LoadConfig(cfg interface{}) error {
	{{- if eq .Config.Type "viper" }}
	viper.SetConfigName("config")
	viper.AddConfigPath(".")
	if err := viper.ReadInConfig(); err != nil {
		return err
	}
	return viper.Unmarshal(cfg)
	{{- else if eq .Config.Type "envconfig" }}
	return envconfig.Process("", cfg)
	{{- else }}
	return nil
	{{- end }}
}
