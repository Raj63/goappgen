// Package main is the entry point for the goappgen CLI.
package main

import (
	"fmt"
	"os"
	"runtime/debug"

	"github.com/Raj63/goappgen/cmd/ops"
)

// main is the entry point for the goappgen CLI application.
// It delegates execution to the ops package.
func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Fprintf(os.Stderr, "\nPANIC: %v\n%s\n", r, debug.Stack())
			os.Exit(2)
		}
	}()
	ops.Execute()
}
