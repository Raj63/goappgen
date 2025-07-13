.PHONY: all build run docker-up docker-down

all: build

build:
{{- range .App }}
	cd {{ .Name }} && go build -o bin/{{ .Name }}
{{- end }}

run:
{{- range .App }}
	cd {{ .Name }} && go run main.go &
{{- end }}

stop:
	pkill -f goappgen || true

docker-up:
	docker-compose up --build

docker-down:
	docker-compose down

test:
	go test ./...

fmt:
	gofmt -w .

modtidy:
	go mod tidy

init:
{{- range .App }}
	cd apps/{{ .Name }} && go mod download && go mod tidy;
{{- end }}
	go work sync

local-ci:
	act -P ubuntu-latest=catthehacker/ubuntu:act-latest -W .github/workflows/ci.yml --container-architecture linux/amd64
