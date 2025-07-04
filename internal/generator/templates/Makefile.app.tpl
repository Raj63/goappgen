.PHONY: build run docker-up docker-down test fmt modtidy

build:
	go build -o bin/{{ .Name }}

run:
	go run main.go

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

{{- if .DevTools.Swagger }}
swagger:
	swag init --parseDependency --parseInternal --output ./docs
{{- end }}
