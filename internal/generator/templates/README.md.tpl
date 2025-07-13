# Go Monorepo

This repository contains the following Go applications:

{{- range .App }}

- **{{ .Name }}**: {{ .Description }}
{{- end }}

## Structure

```yaml
output/
  apps/
{{- range .App }}
    {{ .Name }}/
{{- end }}
  docker-compose.yml
  go.work
  Makefile
  README.md
```

## How to Build and Run

- **Build all apps:**

  ```sh
  make build
  ```

- **Run all apps locally:**

  ```sh
  make run
  ```

- **Start all services with Docker Compose:**

  ```sh
  make docker-up
  ```

- **Stop all Docker Compose services:**

  ```sh
  make docker-down
  ```

Each app's code is in its own subfolder under `apps/`. See each app's README for details.

## Initialize All App Dependencies

To install all Go dependencies for every app and sync the workspace, run:

```sh
make init
```

This will:
- Run `go mod download` and `go mod tidy` in every app under `apps/`
- Run `go work sync` at the root to update the workspace
