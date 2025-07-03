// Package main is the entry point for the goappgen CLI.
package main

import "github.com/Raj63/goappgen/cmd/ops"

// main is the entry point for the goappgen CLI application.
// It delegates execution to the ops package.
func main() {
	ops.Execute()
}
