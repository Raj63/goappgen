import (
	"context"
	"database/sql"
	_ "github.com/mattn/go-sqlite3"
)

func InitDB(ctx context.Context, cfg *Config) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", cfg.DatabaseDSN)
	if err != nil {
		return nil, err
	}
	{{- if .Database.Migrations }}
	if err := RunMigrations(cfg.DatabaseDSN); err != nil {
		return nil, err
	}
	{{- end }}
	return db, nil
}
