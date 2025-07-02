BUILD_DIR := bin
APP_NAME := goappgen
.DEFAULT_GOAL:=help

.PHONY: all clean build test run help precommit

all: clean test build run ## Run all tests, then build and run

build: ## build artifacts
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(APP_NAME) ./cmd 

clean: ## Clean up, i.e. remove build artifacts
	rm -rf $(BUILD_DIR)
	@go mod tidy

run: build ## Run the binary
	$(BUILD_DIR)/$(APP_NAME)

.PHONY: test ## Run tests
test:
	go test -race -cover -coverprofile=coverage.txt -covermode=atomic ./...

help: ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

precommit: ## Run precommit checks
	pre-commit run --all-files