name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: 1.23
      - name: Install golangci-lint v2
        run: go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.2.1
      - name: Lint
        run: golangci-lint run ./...
      - name: Build
        run: go build ./...
      - name: Test
        run: go test -v ./...
