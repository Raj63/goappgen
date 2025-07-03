{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.go_1_23
    pkgs.golangci-lint
    pkgs.gotools
    pkgs.gopls
    pkgs.pre-commit
  ];
}
