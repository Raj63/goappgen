# goappgen

`goappgen` is a CLI tool to generate production-grade Go application scaffolding from a YAML or JSON configuration file. It automates the setup of new Go services, providing best practices and common tooling out of the box.

## Project Structure
```
goappgen/
├── cmd/                  # CLI entrypoints and subcommands
│   ├── main.go           # Main CLI entrypoint
│   └── ops/              # CLI subcommands (generate, init, version, root)
│       ├── generate.go
│       ├── init.go
│       ├── root.go
│       └── version.go
├── internal/
│   ├── config/           # Config parsing/types
│   │   ├── parser.go
│   │   └── types.go
│   └── generator/        # App scaffolding logic and templates
│       ├── generator.go
│       └── templates/    # All templates for generated projects
│           ├── main.go.tpl, Dockerfile.tpl, ...
│           ├── configs/ ...
│           ├── internal/ ...
│           ├── .github/ ...
│           ├── scripts/ ...
│           └── ...
├── .github/              # GitHub Actions workflows
│   └── workflows/
│       └── ci.yml
├── scripts/              # Project-level scripts
│   └── test.sh
├── bin/                  # Build output (gitignored)
├── sample.yaml           # Example config for single-app mode
├── multi-app.yaml        # Example config for multi-app mode
├── Makefile              # Build, test, and dev automation
├── shell.nix             # Nix shell for reproducible dev environments
├── go.mod, go.sum        # Go module files
├── .gitignore, .editorconfig, .prettierrc, .golangci.yml, .pre-commit-config.yaml, .tool-versions
├── README.md, LICENSE, CHANGELOG.md, CONTRIBUTING.md, CODEOWNERS
```

## Features

- Generate Go application structure from a config file
- Supports HTTP (Gin, Echo, Fiber, Chi), gRPC, logging, config providers, CLI, authentication, database, observability, and dev tools
- Uses templates for main.go, Dockerfile, and more
- Extensible and easy to customize

## How It Works

1. Write a YAML or JSON config describing your app (see below for examples).
2. Run `goappgen generate -c sample.yaml -o ./output [--sync-go-mod]`.
3. The tool generates a ready-to-use Go app scaffold in the output directory.

---

## Example: Single-App Mode

```yaml
app:
  - name: inventory-service
    description: Inventory microservice
    transport:
      http: gin         # Options: gin, echo, chi
      grpc: true        # Set to true to enable gRPC
    logger:
      type: slog       # Options: slog, zap, zerolog, logrus
      output: std      # Options: std, file, both
    config:
      type: viper      # Options: viper, envconfig
    cli:
      cobra: true      # Set to true to enable Cobra CLI
    auth:
      type: jwt        # Options: jwt, casbin, none
    database:
      type: postgres   # Options: postgres, mysql, sqlite, mongo
      orm: sqlc        # Options: sqlc, gorm, pgx
      cqrs: true       # Enable CQRS pattern
      migrations: true # Enable DB migrations
    observability:
      metrics: prometheus   # Options: prometheus, none
      tracing: otel         # Options: otel, none
      logs: loki            # Options: loki, none
    storage:
      type: s3              # Options: s3, minio, none
      bucket: my-bucket
    devtools:
      docker: true
      docker_compose: true
      air: true
      makefile: true
      precommit: true
      kubernetes: true      # Enable Kubernetes manifests
      docker_compose: false # Only generate k8s manifests
    middlewares:
      cors:
        enabled: true
        allow_origins: ["*"]
        allow_methods: ["GET", "POST", "PUT", "DELETE"]
        allow_headers: ["Authorization", "Content-Type"]
      ratelimiter:
        enabled: true
        requests_per_second: 10
        burst: 20
      exception_handler:
        enabled: true
      record_metrics:
        enabled: true
      options:
        enabled: true
```

---

## Example: Multi-App Monorepo Mode

```yaml
app:
  - name: inventory-service
    description: Inventory microservice
    transport:
      http: echo         # Options: gin, echo, chi
      grpc: true
    logger:
      type: zap          # Options: slog, zap, zerolog, logrus
      output: file
    config:
      type: envconfig    # Options: viper, envconfig
    cli:
      cobra: true
    auth:
      type: casbin       # Options: jwt, casbin, none
    database:
      type: mysql        # Options: postgres, mysql, sqlite, mongo
      orm: gorm          # Options: sqlc, gorm, pgx
      migrations: true
    observability:
      metrics: prometheus
      tracing: otel
      logs: loki
    storage:
      type: minio
      bucket: inventory-bucket
    devtools:
      docker: true
      docker_compose: true
      air: true
      makefile: true
      precommit: true
      kubernetes: true
      docker_compose: false

  - name: user-service
    description: User management microservice
    transport:
      http: chi
      grpc: false
    logger:
      type: zerolog
      output: std
    config:
      type: viper
    cli:
      cobra: false
    auth:
      type: jwt
    database:
      type: mongo
      orm: ""
      migrations: false
    observability:
      metrics: none
      tracing: none
      logs: none
    storage:
      type: none
      bucket: ""
    devtools:
      docker: true
      docker_compose: true
      air: false
      makefile: true
      precommit: false
      kubernetes: true
      docker_compose: true
    middlewares:
      cors:
        enabled: false
      ratelimiter:
        enabled: false
      exception_handler:
        enabled: true
      record_metrics:
        enabled: true
      options:
        enabled: true
```

---

### Output Structure for Kubernetes
- **Single-app mode:**
  - `output/app/<appname>/k8s/` contains `deployment.yaml`, `service.yaml`, `ingress.yaml`
- **Multi-app mode:**
  - `output/k8s/<appname>/` contains k8s manifests for each app

---

### **Config Field Reference**
- **transport.http**: `gin`, `echo`, `chi`
- **transport.grpc**: `true`/`false`
- **logger.type**: `slog`, `zap`, `zerolog`, `logrus`
- **logger.output**: `std`, `file`, `both`
- **config.type**: `viper`, `envconfig`
- **cli.cobra**: `true`/`false`
- **auth.type**: `jwt`, `casbin`, `none`
- **devtools.kubernetes**: `true`/`false` (enable Kubernetes manifests)
- **devtools.docker_compose**: `true`/`false` (enable Docker Compose)

---

### Middleware Options
- **cors**: Enable CORS with configurable origins, methods, and headers.
- **ratelimiter**: Enable request rate limiting (requests per second, burst).
- **exception_handler**: Enable global exception/recovery handler.
- **record_metrics**: Enable HTTP/gRPC metrics collection.
- **options**: Enable automatic OPTIONS handler for CORS preflight.

### CLI Flags

- `--sync-go-mod` (optional): After generation, run `go mod download && go mod tidy` (single-app) or `go work sync` (multi-app) in the output directory. This ensures dependencies are downloaded and the Go module/workspace is up to date. Recommended for most use cases.

## Output Structure

```
output/
  apps/
    <app1>/
    <app2>/
    ...
  docker-compose.yml
  go.work
  Makefile
  README.md
```
