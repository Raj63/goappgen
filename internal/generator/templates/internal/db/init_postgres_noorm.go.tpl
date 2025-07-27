import (
	"context"
	"database/sql"
	_ "github.com/lib/pq"
)

func InitDB(ctx context.Context, cfg *Config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.DatabaseDSN)
	if err != nil {
		return nil, err
	}
	return db, nil
}
