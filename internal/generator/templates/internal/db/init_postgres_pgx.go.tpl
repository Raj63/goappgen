import (
	"context"
	"github.com/jackc/pgx/v5"
)

func InitDB(ctx context.Context, cfg *Config) (*pgx.Conn, error) {
	conn, err := pgx.Connect(ctx, cfg.DatabaseDSN)
	if err != nil {
		return nil, err
	}
	{{- if .Database.Migrations }}
	if err := RunMigrations(cfg.DatabaseDSN); err != nil {
		return nil, err
	}
	{{- end }}
	return conn, nil
}
