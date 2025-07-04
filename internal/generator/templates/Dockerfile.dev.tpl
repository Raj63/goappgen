FROM golang:1.24

WORKDIR /app
COPY . .

RUN go mod tidy
RUN go install github.com/cosmtrek/air@latest

CMD ["air", "-c", "air.toml"]
