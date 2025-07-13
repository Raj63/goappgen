package generator

import (
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/Raj63/goappgen/internal/config"
)

func TestGenerateAll_SingleApp(t *testing.T) {
	cfg := config.AppConfig{
		App: []config.App{
			{
				Name:        "testapp",
				Description: "A test app",
				Transport:   config.Transport{HTTPFramework: "gin", GRPC: false},
				Logger:      config.Logger{Type: "zap", Output: "std"},
				Config:      config.Provider{Type: "viper"},
				CLI:         config.CLI{UseCobra: true},
				Auth:        config.Auth{Type: "jwt"},
				Database:    config.Database{Type: "postgres", ORM: "gorm", CQRS: false, Migrations: true},
				Observability: config.Observability{
					Metrics: config.Metrics{
						Enabled: true,
						Type:    "prometheus",
					},
					Tracing: config.Tracing{
						Enabled: true,
						Type:    "otel",
					},
					Logs: "loki",
				},
				DevTools:    config.DevTools{Docker: true, DockerCompose: true, Air: true, Makefile: true, Precommit: true, Kubernetes: true, Swagger: true},
				Storage:     config.Storage{Type: "s3", Endpoint: "http://minio:9000", AccessKey: "minio", SecretKey: "minio123", Bucket: "test", Region: "us-east-1", UseSSL: false},
				Middlewares: config.Middlewares{},
			},
		},
	}
	outputDir := "test_output/single"
	if err := os.RemoveAll(outputDir); err != nil {
		t.Fatalf("failed to remove outputDir: %v", err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(outputDir); err != nil {
			t.Errorf("failed to remove outputDir: %v", err)
		}
	})
	err := GenerateAll(cfg, outputDir)
	if err != nil {
		t.Fatalf("GenerateAll failed: %v", err)
	}
	// Check that main.go was generated
	mainPath := filepath.Join(outputDir, "apps", "testapp", "main.go")
	if _, err := os.Stat(mainPath); err != nil {
		t.Errorf("main.go not generated: %v", err)
	}
}

func TestGenerateAll_MultiApp(t *testing.T) {
	cfg := config.AppConfig{
		App: []config.App{
			{
				Name:        "app1",
				Description: "App 1",
				Transport:   config.Transport{HTTPFramework: "echo", GRPC: true},
				Logger:      config.Logger{Type: "logrus", Output: "std"},
				Config:      config.Provider{Type: "envconfig"},
				CLI:         config.CLI{UseCobra: true},
				Auth:        config.Auth{Type: "casbin"},
				Database:    config.Database{Type: "mysql", ORM: "gorm", CQRS: true, Migrations: true},
				Observability: config.Observability{
					Metrics: config.Metrics{
						Enabled: true,
						Type:    "prometheus",
					},
					Tracing: config.Tracing{
						Enabled: true,
						Type:    "otel",
					},
					Logs: "loki",
				},
				DevTools:    config.DevTools{Docker: true, DockerCompose: true, Air: true, Makefile: true, Precommit: true, Kubernetes: true, Swagger: true},
				Storage:     config.Storage{Type: "minio", Endpoint: "http://minio:9000", AccessKey: "minio", SecretKey: "minio123", Bucket: "test", Region: "us-east-1", UseSSL: false},
				Middlewares: config.Middlewares{},
			},
			{
				Name:          "app2",
				Description:   "App 2",
				Transport:     config.Transport{HTTPFramework: "fiber", GRPC: false},
				Logger:        config.Logger{Type: "zerolog", Output: "std"},
				Config:        config.Provider{Type: "viper"},
				CLI:           config.CLI{UseCobra: false},
				Auth:          config.Auth{Type: "jwt"},
				Database:      config.Database{Type: "postgres", ORM: "pgx", CQRS: false, Migrations: false},
				Observability: config.Observability{Logs: "none"},
				DevTools:      config.DevTools{Docker: true, DockerCompose: false, Air: false, Makefile: true, Precommit: false, Kubernetes: false, Swagger: false},
				Storage:       config.Storage{Type: "none"},
				Middlewares:   config.Middlewares{},
			},
		},
	}
	outputDir := "test_output/multi"
	if err := os.RemoveAll(outputDir); err != nil {
		t.Fatalf("failed to remove outputDir: %v", err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(outputDir); err != nil {
			t.Errorf("failed to remove outputDir: %v", err)
		}
	})
	err := GenerateAll(cfg, outputDir)
	if err != nil {
		t.Fatalf("GenerateAll failed: %v", err)
	}
	main1 := filepath.Join(outputDir, "apps", "app1", "main.go")
	main2 := filepath.Join(outputDir, "apps", "app2", "main.go")
	if _, err := os.Stat(main1); err != nil {
		t.Errorf("main.go for app1 not generated: %v", err)
	}
	if _, err := os.Stat(main2); err != nil {
		t.Errorf("main.go for app2 not generated: %v", err)
	}
}

func TestPrintFileStructure_DryRun(t *testing.T) {
	cfg := config.AppConfig{
		App: []config.App{
			{
				Name:          "dryrunapp",
				Description:   "Dry run app",
				Transport:     config.Transport{HTTPFramework: "chi", GRPC: false},
				Logger:        config.Logger{Type: "slog", Output: "std"},
				Config:        config.Provider{Type: "viper"},
				CLI:           config.CLI{UseCobra: true},
				Auth:          config.Auth{Type: "jwt"},
				Database:      config.Database{Type: "sqlite", ORM: "gorm", CQRS: false, Migrations: false},
				Observability: config.Observability{Logs: "none"},
				DevTools:      config.DevTools{Docker: true, DockerCompose: true, Air: false, Makefile: true, Precommit: false, Kubernetes: false, Swagger: false},
				Storage:       config.Storage{Type: "none"},
				Middlewares:   config.Middlewares{},
			},
		},
	}
	outputDir := "test_output/dryrun"
	if err := os.RemoveAll(outputDir); err != nil {
		t.Fatalf("failed to remove outputDir: %v", err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(outputDir); err != nil {
			t.Errorf("failed to remove outputDir: %v", err)
		}
	})

	// Capture stdout
	old := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	err := printFileStructure(cfg, outputDir)
	if err != nil {
		t.Fatalf("printFileStructure failed: %v", err)
	}
	if err := w.Close(); err != nil {
		t.Errorf("failed to close writer: %v", err)
	}
	os.Stdout = old

	if err != nil {
		t.Fatalf("printFileStructure failed: %v", err)
	}
	outBytes, _ := io.ReadAll(r)
	out := string(outBytes)
	if !strings.Contains(out, "dryrunapp") {
		t.Errorf("Dry run output missing app name: %s", out)
	}
	if strings.Contains(out, "main.go not generated") {
		t.Errorf("Dry run should not generate files")
	}
}

func TestGenerateAll_EmptyConfig(t *testing.T) {
	cfg := config.AppConfig{App: []config.App{}}
	outputDir := "test_output/empty"
	t.Cleanup(func() {
		if err := os.RemoveAll(outputDir); err != nil {
			t.Errorf("failed to remove outputDir: %v", err)
		}
	})
	err := GenerateAll(cfg, outputDir)
	if err != nil {
		t.Errorf("GenerateAll with empty config should not error, got: %v", err)
	}
	appsDir := filepath.Join(outputDir, "apps")
	if _, err := os.Stat(appsDir); !os.IsNotExist(err) {
		t.Errorf("No apps should be generated for empty config")
	}
}

func TestGenerateAll_K8sManifests(t *testing.T) {
	cfg := config.AppConfig{
		App: []config.App{
			{
				Name:        "k8sapp",
				Description: "App with k8s",
				Transport:   config.Transport{HTTPFramework: "gin", GRPC: false},
				Logger:      config.Logger{Type: "zap", Output: "std"},
				Config:      config.Provider{Type: "viper"},
				CLI:         config.CLI{UseCobra: true},
				Auth:        config.Auth{Type: "jwt"},
				Database:    config.Database{Type: "postgres", ORM: "gorm", CQRS: false, Migrations: true},
				Observability: config.Observability{
					Metrics: config.Metrics{
						Enabled: true,
						Type:    "prometheus",
					},
					Tracing: config.Tracing{
						Enabled: true,
						Type:    "otel",
					},
					Logs: "loki",
				},
				DevTools:    config.DevTools{Kubernetes: true},
				Storage:     config.Storage{Type: "none"},
				Middlewares: config.Middlewares{},
			},
			{
				Name:          "nok8sapp",
				Description:   "App without k8s",
				Transport:     config.Transport{HTTPFramework: "echo", GRPC: false},
				Logger:        config.Logger{Type: "logrus", Output: "std"},
				Config:        config.Provider{Type: "viper"},
				CLI:           config.CLI{UseCobra: true},
				Auth:          config.Auth{Type: "jwt"},
				Database:      config.Database{Type: "postgres", ORM: "gorm", CQRS: false, Migrations: true},
				Observability: config.Observability{Logs: "none"},
				DevTools:      config.DevTools{Kubernetes: false},
				Storage:       config.Storage{Type: "none"},
				Middlewares:   config.Middlewares{},
			},
		},
	}
	outputDir := "test_output"
	t.Cleanup(func() {
		if err := os.RemoveAll(outputDir); err != nil {
			t.Errorf("failed to remove outputDir: %v", err)
		}
	})
	err := GenerateAll(cfg, outputDir)
	if err != nil {
		t.Fatalf("GenerateAll failed: %v", err)
	}
	k8sPath := filepath.Join(outputDir, "k8s", "k8sapp", "deployment.yaml")
	if _, err := os.Stat(k8sPath); err != nil {
		t.Errorf("K8s manifest not generated for k8sapp: %v", err)
	}
	k8sPathNo := filepath.Join(outputDir, "k8s", "nok8sapp", "deployment.yaml")
	if _, err := os.Stat(k8sPathNo); !os.IsNotExist(err) {
		t.Errorf("K8s manifest should not be generated for nok8sapp")
	}
}

func TestPrintFileStructure_DryRun_MultiApp(t *testing.T) {
	cfg := config.AppConfig{
		App: []config.App{
			{Name: "appA", DevTools: config.DevTools{Kubernetes: true}},
			{Name: "appB", DevTools: config.DevTools{Kubernetes: false}},
		},
	}
	outputDir := "test_output/dryrunmulti"
	if err := os.RemoveAll(outputDir); err != nil {
		t.Fatalf("failed to remove outputDir: %v", err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(outputDir); err != nil {
			t.Errorf("failed to remove outputDir: %v", err)
		}
	})
	old := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	err := printFileStructure(cfg, outputDir)
	if err != nil {
		t.Fatalf("printFileStructure failed: %v", err)
	}
	if err := w.Close(); err != nil {
		t.Errorf("failed to close writer: %v", err)
	}
	os.Stdout = old

	if err != nil {
		t.Fatalf("printFileStructure failed: %v", err)
	}
	outBytes, _ := io.ReadAll(r)
	out := string(outBytes)
	if !strings.Contains(out, "appA") || !strings.Contains(out, "appB") {
		t.Errorf("Dry run output missing app names: %s", out)
	}
	if !strings.Contains(out, "k8sapp") && !strings.Contains(out, "k8s/") {
		t.Errorf("Dry run output missing k8s manifests: %s", out)
	}
}
