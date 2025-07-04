# syntax=docker/dockerfile:1
FROM golang:1.24

WORKDIR /app
COPY . .

RUN go mod tidy
RUN go build -o {{ .Name }}
RUN {{ if .DevTools.Air }}go install github.com/cosmtrek/air@latest{{ else }}echo "no air"{{ end }}
CMD {{ if .DevTools.Air }}["air", "-c", "air.toml"]{{ else }}["./{{ .Name }}"]{{ end }}
