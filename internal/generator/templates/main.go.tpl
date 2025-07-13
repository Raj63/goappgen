package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	// Logger imports
	{{ include "slog_imports.go.tpl" }}
	{{ include "zap_imports.go.tpl" }}
	{{ include "zerolog_imports.go.tpl" }}
	{{ include "logrus_imports.go.tpl" }}

    {{- if eq .Observability.Logs "loki"}}
        lokilogger "{{ .Name }}/internal/logger"
    {{- end }}

	// Config imports
	{{ include "config_imports.go.tpl" }}

	// HTTP Framework imports
	{{ include "gin_imports.go.tpl" }}
	{{ include "echo_imports.go.tpl" }}
	{{ include "chi_imports.go.tpl" }}
	{{ include "fiber_imports.go.tpl" }}

	// gRPC imports
	{{ include "grpc_imports.go.tpl" }}

	// Database imports
	{{ include "database_imports.go.tpl" }}

	// Auth imports
	{{ include "auth_imports.go.tpl" }}

	// Swagger imports
	{{ include "swagger_imports.go.tpl" }}

	// Standard library imports
	"net/http"
	"{{ .Name }}/internal/shutdown"
)

func main() {
	ctx := shutdown.SetupGracefulShutdown(func() {
		// TODO: Add cleanup logic here
		fmt.Println("Shutting down...")
	})

	// Logger setup
	{{ include "slog_code.go.tpl" }}
	{{ include "zap_code.go.tpl" }}
	{{ include "zerolog_code.go.tpl" }}
	{{ include "logrus_code.go.tpl" }}

    // Hook loki if enabled
    {{- if eq .Observability.Logs "loki"}}
       logger = lokilogger.InitLokiLogger(logger)
    {{- end }}

	// Config setup
	{{ include "config_code.go.tpl" }}

	// Database setup
	{{ include "database_code.go.tpl" }}

	// Migrations
	{{ include "database_migrations.go.tpl" }}

	// Auth setup
	{{ include "auth_code.go.tpl" }}

	// Plugins setup
    initPlugins("{{ .Name }}")

	// HTTP server setup
	{{ include "gin-server_code.go.tpl" }}
	{{ include "echo-server_code.go.tpl" }}
	{{ include "chi-server_code.go.tpl" }}
	{{ include "fiber-server_code.go.tpl" }}

	// gRPC server setup
	{{ include "grpc-server_code.go.tpl" }}

	// Graceful shutdown
	<-ctx.Done()
}
