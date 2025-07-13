package config

// AppConfig represents the root configuration structure for goappgen.
type AppConfig struct {
	App []App `yaml:"app" json:"app"`
}

// App represents a single application configuration for code generation.
type App struct {
	Name          string        `yaml:"name" json:"name"`
	Description   string        `yaml:"desc" json:"desc"`
	Transport     Transport     `yaml:"transport" json:"transport"`                             // HTTP/GRPC
	Logger        Logger        `yaml:"logger" json:"logger"`                                   // slog/zap/logrus/zerolog
	Config        Provider      `yaml:"config" json:"config"`                                   // viper/env
	CLI           CLI           `yaml:"cli" json:"cli"`                                         // cobra
	Auth          Auth          `yaml:"auth,omitempty" json:"auth,omitempty"`                   // casbin/jwt
	Database      Database      `yaml:"database" json:"database"`                               // postgres/sqlite/mongo + orm/migrations
	Observability Observability `yaml:"observability,omitempty" json:"observability,omitempty"` // prometheus/otel
	DevTools      DevTools      `yaml:"devtools" json:"devtools"`                               // docker, air, makefile, precommit, etc.
	Storage       Storage       `yaml:"storage" json:"storage"`                                 // S3/MinIO storage
	Middlewares   Middlewares   `yaml:"middlewares" json:"middlewares"`
}

// Transport defines the transport layer configuration (HTTP/GRPC) for the app.
type Transport struct {
	HTTPFramework string `yaml:"http,omitempty" json:"http,omitempty"` // gin/echo/fiber/chi
	GRPC          bool   `yaml:"grpc,omitempty" json:"grpc,omitempty"` // true/false
}

// Logger specifies the logging configuration for the app.
type Logger struct {
	Type   string `yaml:"type" json:"type"`     // slog/zap/logrus/zerolog
	Output string `yaml:"output" json:"output"` // std/file/both
}

// Provider defines the configuration provider (e.g., viper, envconfig) for the app.
type Provider struct {
	Type string `yaml:"type" json:"type"` // viper/envconfig/none
}

// CLI specifies the command-line interface configuration for the app.
type CLI struct {
	UseCobra bool `yaml:"cobra" json:"cobra"` // default true
}

// Auth defines the authentication configuration for the app.
type Auth struct {
	Type string `yaml:"type" json:"type"` // casbin/jwt/jwks/goth
}

// Database specifies the database and ORM configuration for the app.
type Database struct {
	Type       string `yaml:"type" json:"type"`             // postgres/sqlite/mongo/mysql/mariadb
	ORM        string `yaml:"orm" json:"orm"`               // gorm/sqlc/pgx/none
	CQRS       bool   `yaml:"cqrs" json:"cqrs"`             // true/false
	Migrations bool   `yaml:"migrations" json:"migrations"` // true/false
}

// Observability defines observability options like metrics, tracing, and logs for the app.
type Observability struct {
	Metrics Metrics `yaml:"metrics" json:"metrics"`
	Tracing Tracing `yaml:"tracing" json:"tracing"`
	Logs    string  `yaml:"logs" json:"logs"` // loki/none
}

// Metrics holds configuration for metrics collection.
type Metrics struct {
	Enabled bool   `yaml:"enabled" json:"enabled"`
	Type    string `yaml:"type" json:"type"` // prometheus/none
}

// Tracing holds configuration for distributed tracing.
type Tracing struct {
	Enabled bool   `yaml:"enabled" json:"enabled"`
	Type    string `yaml:"type" json:"type"` // otel/jaeger/none
}

// DevTools specifies which development tools should be included in the generated app.
type DevTools struct {
	Docker        bool `yaml:"docker" json:"docker"`
	DockerCompose bool `yaml:"docker_compose" json:"docker_compose"`
	Air           bool `yaml:"air" json:"air"`
	Makefile      bool `yaml:"makefile" json:"makefile"`
	Precommit     bool `yaml:"precommit" json:"precommit"`
	Kubernetes    bool `yaml:"kubernetes" json:"kubernetes"`
	Swagger       bool `yaml:"swagger" json:"swagger"` // Enable Swagger/Swaggo docs
}

// Storage defines the S3-compatible storage configuration for the app.
type Storage struct {
	Type      string `yaml:"type" json:"type"`         // s3, minio, none
	Endpoint  string `yaml:"endpoint" json:"endpoint"` // S3/MinIO endpoint
	AccessKey string `yaml:"access_key" json:"access_key"`
	SecretKey string `yaml:"secret_key" json:"secret_key"`
	Bucket    string `yaml:"bucket" json:"bucket"`
	Region    string `yaml:"region" json:"region"`
	UseSSL    bool   `yaml:"use_ssl" json:"use_ssl"`
}

// CORSConfig holds configuration for CORS middleware.
type CORSConfig struct {
	Enabled      bool     `yaml:"enabled" json:"enabled"`
	AllowOrigins []string `yaml:"allow_origins" json:"allow_origins"`
	AllowMethods []string `yaml:"allow_methods" json:"allow_methods"`
	AllowHeaders []string `yaml:"allow_headers" json:"allow_headers"`
}

// RateLimiterConfig holds configuration for rate limiting middleware.
type RateLimiterConfig struct {
	Enabled           bool `yaml:"enabled" json:"enabled"`
	RequestsPerSecond int  `yaml:"requests_per_second" json:"requests_per_second"`
	Burst             int  `yaml:"burst" json:"burst"`
}

// ExceptionHandlerConfig holds configuration for exception handler middleware.
type ExceptionHandlerConfig struct {
	Enabled bool `yaml:"enabled" json:"enabled"`
}

// RecordMetricsConfig holds configuration for metrics middleware.
type RecordMetricsConfig struct {
	Enabled bool `yaml:"enabled" json:"enabled"`
}

// OptionsConfig holds configuration for automatic OPTIONS handler middleware.
type OptionsConfig struct {
	Enabled bool `yaml:"enabled" json:"enabled"`
}

// LoggingConfig holds configuration for logging middleware.
type LoggingConfig struct {
	Enabled bool `yaml:"enabled" json:"enabled"`
}

// Middlewares aggregates all middleware configuration for an app.
type Middlewares struct {
	CORS             CORSConfig             `yaml:"cors" json:"cors"`
	RateLimiter      RateLimiterConfig      `yaml:"ratelimiter" json:"ratelimiter"`
	ExceptionHandler ExceptionHandlerConfig `yaml:"exception_handler" json:"exception_handler"`
	RecordMetrics    RecordMetricsConfig    `yaml:"record_metrics" json:"record_metrics"`
	Options          OptionsConfig          `yaml:"options" json:"options"`
	Logging          LoggingConfig          `yaml:"logging" json:"logging"`
	Tracing          TracingConfig          `yaml:"tracing" json:"tracing"`
	RequestID        RequestIDConfig        `yaml:"request_id" json:"request_id"`
}

// TracingConfig holds configuration for tracing middleware.
type TracingConfig struct {
	Enabled bool `yaml:"enabled" json:"enabled"`
}

// RequestIDConfig holds configuration for request ID middleware.
type RequestIDConfig struct {
	Enabled bool `yaml:"enabled" json:"enabled"`
}
