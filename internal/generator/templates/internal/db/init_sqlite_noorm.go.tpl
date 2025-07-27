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
	return db, nil
}
