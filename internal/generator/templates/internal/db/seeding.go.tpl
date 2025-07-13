package db

import (
	"context"
	"fmt"
	"os"
	{{- if eq .Database.ORM "gorm" }}
	"gorm.io/gorm"
	{{- else if eq .Database.ORM "pgx" }}
	"github.com/jackc/pgx/v5"
	{{- else if eq .Database.ORM "sqlc" }}
	"database/sql"
	{{- end }}
	{{- if eq .Database.Type "mongo" }}
	"go.mongodb.org/mongo-driver/mongo"
	{{- end }}
)

// SeedData represents the data to be seeded.
type SeedData struct {
	// Add your seed data structures here
}

// RunSeeding runs database seeding if enabled.
func RunSeeding(ctx context.Context, db interface{}) error {
	{{- if .Database.Migrations }}
	seedData := &SeedData{}

	{{- if eq .Database.ORM "gorm" }}
	if gormDB, ok := db.(*gorm.DB); ok {
		return seedWithGORM(gormDB, seedData)
	}
	{{- else if eq .Database.ORM "pgx" }}
	if pgxConn, ok := db.(*pgx.Conn); ok {
		return seedWithPGX(ctx, pgxConn, seedData)
	}
	{{- else if eq .Database.ORM "sqlc" }}
	if sqlDB, ok := db.(*sql.DB); ok {
		return seedWithSQLC(ctx, sqlDB, seedData)
	}
	{{- else if eq .Database.Type "mongo" }}
	if mongoClient, ok := db.(*mongo.Client); ok {
		return seedWithMongo(ctx, mongoClient, seedData)
	}
	{{- end }}
	{{- end }}
	return nil
}

{{- if eq .Database.ORM "gorm" }}
func seedWithGORM(db *gorm.DB, data *SeedData) error {
	return nil
}
{{- end }}

{{- if eq .Database.ORM "pgx" }}
func seedWithPGX(ctx context.Context, conn *pgx.Conn, data *SeedData) error {
	return nil
}
{{- end }}

{{- if eq .Database.ORM "sqlc" }}
func seedWithSQLC(ctx context.Context, db *sql.DB, data *SeedData) error {
	return nil
}
{{- end }}

{{- if eq .Database.Type "mongo" }}
func seedWithMongo(ctx context.Context, client *mongo.Client, data *SeedData) error {
	return nil
}
{{- end }}

// CreateSeedDataFile creates a sample seed data file.
func CreateSeedDataFile() error {
	{{- if .Database.Migrations }}
	seedContent := `{
  "users": [
    {
      "name": "John Doe",
      "email": "john@example.com"
    }
  ]
}`

	if err := os.WriteFile("seed_data.json", []byte(seedContent), 0644); err != nil {
		return fmt.Errorf("failed to create seed data file: %w", err)
	}
	{{- end }}
	return nil
}
