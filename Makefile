BUILD_DIR := bin
APP_NAME := goappgen
.DEFAULT_GOAL:=help

.PHONY: all clean build run-single run-multi test help precommit

all: clean test build run-single ## Run all tests, then build and run

build: ## build artifacts
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(APP_NAME) ./cmd

clean: ## Clean up, i.e. remove build artifacts
	rm -rf $(BUILD_DIR)
	@go mod tidy

run-single: build ## Run the binary in single app mode
	$(BUILD_DIR)/$(APP_NAME) generate --config sample.yaml --out ./output/single-app --sync-go-mod

run-multi: build ## Run the binary in multi app mode
	$(BUILD_DIR)/$(APP_NAME) generate --config multi-app.yaml --out ./output/multi-app --sync-go-mod

.PHONY: test ## Run tests
test:
	go test -race -cover -coverprofile=coverage.txt -covermode=atomic ./...

help: ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

precommit: ## Run precommit checks
	pre-commit run --all-files

local-ci:
	act -P ubuntu-latest=catthehacker/ubuntu:act-latest -W .github/workflows/ci.yml --container-architecture linux/amd64
