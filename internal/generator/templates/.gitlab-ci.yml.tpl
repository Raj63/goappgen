stages:
  - lint
  - test
  - build
  - docker

golangci-lint:
  stage: lint
  image: golang:1.21
  script:
    - go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    - golangci-lint run ./...

test:
  stage: test
  image: golang:1.21
  script:
    - go test -v ./...

build:
  stage: build
  image: golang:1.21
  script:
    - go build ./...

docker:
  stage: docker
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build . 