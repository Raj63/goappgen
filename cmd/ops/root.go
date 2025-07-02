package ops

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "goappgen",
	Short: "Generate production-grade Go applications from config",
	Long:  `GoAppGen takes a YAML/JSON config and generates full production-ready app scaffolding.`,
}

// Execute runs the root command for the goappgen CLI.
// It is the main entry point for command execution.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
