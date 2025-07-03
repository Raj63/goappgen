# Multi-App Go Monorepo

This repository contains the following Go applications:

{{- range .App }}
- **{{ .Name }}**: {{ .Description }}
{{- end }}

## Structure

```
output/
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

Each app's code is in its own subfolder. See each app's README for details. 