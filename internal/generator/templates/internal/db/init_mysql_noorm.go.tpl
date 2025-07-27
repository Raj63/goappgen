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
	return db, nil
}
