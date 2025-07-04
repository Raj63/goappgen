{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.go_1_24
    pkgs.golangci-lint
    pkgs.gotools
    pkgs.gopls
    pkgs.gosec
    pkgs.gofumpt
    pkgs.golint
    pkgs.go-tools
    pkgs.pre-commit
    pkgs.gitlint
    pkgs.act
  ];
}
