package generator

import (
	"fmt"

	"github.com/Raj63/goappgen/internal/config"
)

// printFileStructure prints the file structure that would be generated without creating files.
func printFileStructure(appConfig config.AppConfig, outputBase string) error {
	fmt.Printf("Would generate the following structure in %s:\n\n", outputBase)

	// Print root-level files
	fmt.Println("Root files:")
	fmt.Printf("  %s/\n", outputBase)
	fmt.Println("  ├── README.md")
	fmt.Println("  ├── Makefile")
	fmt.Println("  ├── docker-compose.yml")
	fmt.Println("  ├── go.work")
	fmt.Println("  ├── .gitignore")
	fmt.Println("  ├── LICENSE")
	fmt.Println("  ├── CONTRIBUTING.md")
	fmt.Println("  ├── CODEOWNERS")
	fmt.Println("  ├── CHANGELOG.md")
	fmt.Println("  ├── shell.nix")
	fmt.Println("  └── scripts/")
	fmt.Println("      └── test.sh")

	// Print apps structure
	fmt.Println("\nApps:")
	for _, app := range appConfig.App {
		fmt.Printf("  %s/apps/%s/\n", outputBase, app.Name)
		fmt.Println("  ├── main.go")
		fmt.Println("  ├── go.mod")
		fmt.Println("  ├── Dockerfile")
		fmt.Println("  ├── Makefile")
		fmt.Println("  ├── air.toml")
		fmt.Println("  ├── docker-compose.app.yml")
		fmt.Println("  ├── configs/")
		fmt.Println("  │   ├── config.go")
		fmt.Println("  │   └── config.yaml")
		fmt.Println("  └── internal/")
		fmt.Println("      ├── logger/")
		fmt.Println("      ├── db/")
		fmt.Println("      ├── health/")
		fmt.Println("      ├── shutdown/")
		if app.Observability.Metrics.Enabled || app.Observability.Tracing.Enabled {
			fmt.Println("      ├── observability/")
		}
		if app.Auth.Type != "" {
			fmt.Println("      ├── auth/")
		}
		if app.Storage.Type == "s3" || app.Storage.Type == "minio" {
			fmt.Println("      └── storage/")
		} else {
			fmt.Println("      └── ...")
		}
	}

	// Print k8s structure
	hasK8s := false
	for _, app := range appConfig.App {
		if app.DevTools.Kubernetes {
			hasK8s = true
			break
		}
	}
	if hasK8s {
		fmt.Println("\nKubernetes manifests:")
		fmt.Printf("  %s/k8s/\n", outputBase)
		for _, app := range appConfig.App {
			if app.DevTools.Kubernetes {
				fmt.Printf("  └── %s/\n", app.Name)
				fmt.Println("      ├── deployment.yaml")
				fmt.Println("      ├── service.yaml")
				fmt.Println("      └── ingress.yaml")
			}
		}
	}

	fmt.Printf("\nTotal apps: %d\n", len(appConfig.App))
	return nil
}
