package ops

import (
	"fmt"

	"github.com/spf13/cobra"
)

const version = "v0.1.0"

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version number",
	Run: func(_ *cobra.Command, _ []string) {
		fmt.Println("goappgen version", version)
	},
}

// init registers the version command with the root command.
func init() {
	rootCmd.AddCommand(versionCmd)
}
