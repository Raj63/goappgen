// Package ops provides CLI subcommands for goappgen.
package ops

import (
	"fmt"
	"log"

	"github.com/Raj63/goappgen/internal/config"
	"github.com/Raj63/goappgen/internal/generator"
	"github.com/spf13/cobra"
)

var (
	configPath   string
	outputPath   string
	templatesDir string
	syncGoMod    bool
)

var generateCmd = &cobra.Command{
	Use:   "generate",
	Short: "Generate app(s) from config",
	Long:  `Generate production-grade Go app scaffolding from a YAML/JSON config.`,
	Run: func(_ *cobra.Command, _ []string) {
		cfg, err := config.LoadConfig(configPath)
		if err != nil {
			log.Fatalf("Error loading config: %v", err)
		}
		err = generator.GenerateAllWithPostGen(*cfg, templatesDir, outputPath, syncGoMod)
		if err != nil {
			log.Fatalf("Error generating apps: %v", err)
		}
		fmt.Println("Generation complete.")
	},
}

// init registers the generate command with the root command and sets up its flags.
func init() {
	rootCmd.AddCommand(generateCmd)

	generateCmd.Flags().StringVarP(&configPath, "config", "c", "sample.yaml", "Path to config file")
	generateCmd.Flags().StringVarP(&outputPath, "out", "o", "./output", "Output directory")
	generateCmd.Flags().StringVar(&templatesDir, "templates", "internal/generator/templates", "Templates directory")
	generateCmd.Flags().BoolVar(&syncGoMod, "sync-go-mod", false, "After generation, run 'go mod download && go mod tidy' (single-app) or 'go work sync' (multi-app) in the output directory.")
}
