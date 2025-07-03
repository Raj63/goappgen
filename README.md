# goappgen

`goappgen` is a CLI tool to generate production-grade Go application scaffolding from a YAML or JSON configuration file. It automates the setup of new Go services, providing best practices and common tooling out of the box.

## Project Structure
```
goappgen/
  ├── cmd/                  # CLI entrypoints and command definitions
  │   ├── main.go           # Main entry for the CLI
  │   └── ops/              # CLI subcommands (generate, version, etc.)
  ├── internal/
  │   ├── config/           # Config parsing and types
  │   └── generator/        # App scaffolding logic and templates
  ├── sample.yaml           # Example configuration file
  ├── Makefile              # Build and test automation
  ├── shell.nix             # Nix shell for reproducible dev environments
  ├── go.mod, go.sum        # Go module files
  └── README.md             # Project documentation
```

## Features
- Generate Go application structure from a config file
- Supports HTTP (Gin, Echo, Fiber, Chi), gRPC, logging, config providers, CLI, authentication, database, observability, and dev tools
- Uses templates for main.go, Dockerfile, and more
- Extensible and easy to customize

## How It Works
1. Write a YAML or JSON config describing your app (see `sample.yaml`).
2. Run `goappgen generate -c sample.yaml -o ./output`.
3. The tool generates a ready-to-use Go app scaffold in the output directory.

## Example Config
```yaml
app:
  - name: inventory-service
    transport:
      http: gin
      grpc: true
    logger:
      type: slog
      output: std
    config:
      type: viper
    cli:
      cobra: true
    auth:
      type: jwt
    database:
      type: postgres
      orm: sqlc
      cqrs: true
      migrations: true
    observability:
      metrics: prometheus
      tracing: otel
      logs: loki
    devtools:
      docker: true
      docker_compose: true
      air: true
      makefile: true
      precommit: true
```

## Development

- **Build:** `make build`
- **Test:** `make test`
- **Lint:** `golangci-lint run`
- **Pre-commit:** `pre-commit run --all-files`

## License
MIT
