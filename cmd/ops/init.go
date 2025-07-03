// Package ops provides CLI subcommands for goappgen.
package ops

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var initCmd = &cobra.Command{
	Use:   "init",
	Short: "Initialize a starter config file (sample.yaml)",
	Run: func(_ *cobra.Command, _ []string) {
		filename := "sample.yaml"
		if _, err := os.Stat(filename); err == nil {
			fmt.Printf("%s already exists. Aborting.\n", filename)
			return
		}
		starter := `app:
  - name: my-service
    desc: Example service
    transport:
      http: gin
      grpc: false
    logger:
      type: slog
      output: std
    config:
      type: viper
    cli:
      cobra: true
    auth:
      type: jwt
    database:
      type: postgres
      orm: gorm
      cqrs: false
      migrations: true
    storage:
      type: s3
      endpoint: http://minio:9000
      access_key: minio
      secret_key: minio123
      bucket: mybucket
      region: us-east-1
      use_ssl: false
    observability:
      metrics: prometheus
      tracing: otel
      logs: loki
    devtools:
      docker: true
      docker_compose: true
      air: true
      makefile: true
      precommit: true
`
		if err := os.WriteFile(filename, []byte(starter), 0600); err != nil {
			fmt.Printf("Failed to write %s: %v\n", filename, err)
			return
		}
		fmt.Printf("Created %s\n", filename)
	},
}

func init() {
	rootCmd.AddCommand(initCmd)
}
