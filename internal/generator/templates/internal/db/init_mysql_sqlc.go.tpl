import (
	"context"
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
)

func InitDB(ctx context.Context, cfg *Config) (*sql.DB, error) {
	db, err := sql.Open("mysql", cfg.DatabaseDSN)
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
