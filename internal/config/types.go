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
	Metrics string `yaml:"metrics" json:"metrics"` // prometheus/none
	Tracing string `yaml:"tracing" json:"tracing"` // otel/jaeger/none
	Logs    string `yaml:"logs" json:"logs"`       // loki/none
}

// DevTools specifies which development tools should be included in the generated app.
type DevTools struct {
	Docker         bool `yaml:"docker" json:"docker"`
	DockerCompose  bool `yaml:"docker_compose" json:"docker_compose"`
	Air            bool `yaml:"air" json:"air"`
	Makefile       bool `yaml:"makefile" json:"makefile"`
	PreCommitHooks bool `yaml:"precommit" json:"precommit"`
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
