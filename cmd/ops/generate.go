package ops

import (
	"fmt"
	"log"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator"
	"github.com/spf13/cobra"
)

var (
	configPath string
	outputPath string
)

var generateCmd = &cobra.Command{
	Use:   "generate",
	Short: "Generate app(s) from config",
	Run: func(cmd *cobra.Command, args []string) {
		cfg, err := config.LoadConfig(configPath)
		if err != nil {
			log.Fatalf("Failed to load config: %v", err)
		}

		for _, app := range cfg.App {
			fmt.Printf("Generating app: %s\n", app.Name)
			if err := generator.GenerateApp(app, "internal/generator/templates", outputPath); err != nil {
				log.Fatalf("Error generating %s: %v", app.Name, err)
			}
		}
		fmt.Println("Done.")
	},
}

// init registers the generate command with the root command and sets up its flags.
func init() {
	rootCmd.AddCommand(generateCmd)

	generateCmd.Flags().StringVarP(&configPath, "config", "c", "config.yaml", "Path to YAML/JSON config file")
	generateCmd.Flags().StringVarP(&outputPath, "out", "o", "./output", "Output directory for generated apps")
}
