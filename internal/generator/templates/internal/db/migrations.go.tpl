package db

import (
	"fmt"
	"os"
	{{- if .Database.Migrations }}
	"github.com/golang-migrate/migrate/v4"
	{{- if eq .Database.Type "postgres" }}
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	{{- else if or (eq .Database.Type "mysql") (eq .Database.Type "mariadb") }}
	"github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	{{- else if eq .Database.Type "sqlite" }}
	"github.com/golang-migrate/migrate/v4/database/sqlite3"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	{{- end }}
	{{- end }}
)

// RunMigrations runs database migrations if enabled.
func RunMigrations(dsn string) error {
	{{- if .Database.Migrations }}
	m, err := migrate.New(
		"file://migrations",
		dsn,
	)
	if err != nil {
		return fmt.Errorf("failed to create migration instance: %w", err)
	}
	defer m.Close()

	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to run migrations: %w", err)
	}
	{{- end }}
	return nil
}

// CreateMigrationsDir creates the migrations directory structure.
func CreateMigrationsDir() error {
	{{- if .Database.Migrations }}
	migrationsDir := "migrations"
	if err := os.MkdirAll(migrationsDir, 0755); err != nil {
		return fmt.Errorf("failed to create migrations directory: %w", err)
	}

	// Create example migration files
	{{- if eq .Database.Type "postgres" }}
	upFile := fmt.Sprintf("%s/001_create_initial_tables.up.sql", migrationsDir)
	downFile := fmt.Sprintf("%s/001_create_initial_tables.down.sql", migrationsDir)
	{{- else if or (eq .Database.Type "mysql") (eq .Database.Type "mariadb") }}
	upFile := fmt.Sprintf("%s/001_create_initial_tables.up.sql", migrationsDir)
	downFile := fmt.Sprintf("%s/001_create_initial_tables.down.sql", migrationsDir)
	{{- else if eq .Database.Type "sqlite" }}
	upFile := fmt.Sprintf("%s/001_create_initial_tables.up.sql", migrationsDir)
	downFile := fmt.Sprintf("%s/001_create_initial_tables.down.sql", migrationsDir)
	{{- end }}

	// Create example up migration
	upContent := `-- Example migration: Create initial tables
-- Add your table creation SQL here
-- Example:
-- CREATE TABLE users (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(255) NOT NULL,
--     email VARCHAR(255) UNIQUE NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
`
	if err := os.WriteFile(upFile, []byte(upContent), 0644); err != nil {
		return fmt.Errorf("failed to create up migration file: %w", err)
	}

	// Create example down migration
	downContent := `-- Example migration: Drop initial tables
-- Add your table deletion SQL here
-- Example:
-- DROP TABLE IF EXISTS users;
`
	if err := os.WriteFile(downFile, []byte(downContent), 0644); err != nil {
		return fmt.Errorf("failed to create down migration file: %w", err)
	}
	{{- end }}
	return nil
}
