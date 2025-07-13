package db

import (
	"context"
	"os"
	// --- GORM Drivers ---
	{{- if and (eq .Database.ORM "gorm") (eq .Database.Type "postgres") }}
	"gorm.io/gorm"
	"gorm.io/driver/postgres"
	{{- else if and (eq .Database.ORM "gorm") (eq .Database.Type "sqlite") }}
	"gorm.io/gorm"
	"gorm.io/driver/sqlite"
	{{- else if and (eq .Database.ORM "gorm") (or (eq .Database.Type "mysql") (eq .Database.Type "mariadb")) }}
	"gorm.io/gorm"
	"gorm.io/driver/mysql"
	{{- end }}
	// --- PGX ---
	{{- if and (eq .Database.ORM "pgx") (eq .Database.Type "postgres") }}
	"github.com/jackc/pgx/v5"
	{{- end }}
	// --- SQLC ---
	{{- if eq .Database.ORM "sqlc" }}
	"database/sql"
	{{- if eq .Database.Type "postgres" }}
	_ "github.com/lib/pq"
	{{- else if eq .Database.Type "mysql" }}
	_ "github.com/go-sql-driver/mysql"
	{{- else if eq .Database.Type "sqlite" }}
	_ "github.com/mattn/go-sqlite3"
	{{- end }}
	{{- end }}
	// --- MongoDB ---
	{{- if eq .Database.Type "mongo" }}
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	{{- end }}
)

// InitDB initializes the database connection and runs migrations if enabled.
func InitDB(ctx context.Context) (interface{}, error) {
	// --- GORM ---
	{{- if eq .Database.ORM "gorm" }}
	var db interface{}
	var err error
	{{- if eq .Database.Type "postgres" }}
	dsn := os.Getenv("DATABASE_DSN")
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	{{- else if eq .Database.Type "sqlite" }}
	dsn := os.Getenv("DATABASE_DSN")
	db, err = gorm.Open(sqlite.Open(dsn), &gorm.Config{})
	{{- else if or (eq .Database.Type "mysql") (eq .Database.Type "mariadb") }}
	dsn := os.Getenv("DATABASE_DSN")
	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	{{- end }}
	if err != nil {
		return nil, err
	}
	{{- if .Database.Migrations }}
	// Run migrations using modular approach
	if err := RunMigrations(dsn); err != nil {
		return nil, err
	}
	{{- end }}
	return db, nil
	// --- PGX ---
	{{- else if and (eq .Database.ORM "pgx") (eq .Database.Type "postgres") }}
	dsn := os.Getenv("DATABASE_DSN")
	conn, err := pgx.Connect(ctx, dsn)
	if err != nil {
		return nil, err
	}
	{{- if .Database.Migrations }}
	// Run migrations using modular approach
	if err := RunMigrations(dsn); err != nil {
		return nil, err
	}
	{{- end }}
	return conn, nil
	// --- SQLC ---
	{{- else if eq .Database.ORM "sqlc" }}
	dsn := os.Getenv("DATABASE_DSN")
	db, err := sql.Open("{{ .Database.Type }}", dsn)
	if err != nil {
		return nil, err
	}
	{{- if .Database.Migrations }}
	// Run migrations using modular approach
	if err := RunMigrations(dsn); err != nil {
		return nil, err
	}
	{{- end }}
	return db, nil
	// --- MongoDB ---
	{{- else if eq .Database.Type "mongo" }}
	uri := os.Getenv("MONGO_URI")
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		return nil, err
	}
	return client, nil
	// --- None or unsupported ---
	{{- else }}
	return nil, nil
	{{- end }}
}
