run:
	go run main.go

build:
	go build -o bin/{{ .Name }}

test:
	go test ./...

fmt:
	gofmt -w .

modtidy:
	go mod tidy
