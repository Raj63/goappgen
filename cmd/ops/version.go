package ops

import (
	"fmt"

	"github.com/spf13/cobra"
)

const version = "v0.1.0"

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version number",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("goappgen version", version)
	},
}

// init registers the version command with the root command.
func init() {
	rootCmd.AddCommand(versionCmd)
}
