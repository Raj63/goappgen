default_stages: [pre-commit]

fail_fast: true

repos:
  - repo: https://github.com/jorisroovers/gitlint
    rev: v0.19.1
    hooks:
      - id: gitlint
        name: Git - Check Commit Message

  - repo: https://github.com/tekwizely/pre-commit-golang
    rev: v1.0.0-rc.1
    hooks:
      #
      # Go Build
      #
      - id: go-build-mod
      #
      # Go Mod Tidy
      #
      - id: go-mod-tidy
      #
      # Go Test
      #
      - id: go-test-mod
      #
      # Go Vet
      #
      - id: go-vet-mod
      #
      # GoSec
      #
      - id: go-sec-mod
      #
      # StaticCheck
      #
      - id: go-staticcheck-mod
      #
      # Formatters
      #
      - id: go-fmt
      #
      # GolangCI-Lint
      #
      - id: golangci-lint-mod
      #
      # Style Checkers
      #
      - id: go-lint

    # Invoking Custom Go Tools
  - repo: local
    hooks:
      - id: unit tests
        name: Run unit tests
        entry: bash -c "make test"
        language: system

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/golangci/golangci-lint
    rev: v2.2.1
    hooks:
      - id: golangci-lint

  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.11.0-1
    hooks:
      - id: shfmt
