import (
	"context"
	"gorm.io/gorm"
	"gorm.io/driver/mysql"
)

func InitDB(ctx context.Context, cfg *Config) (*gorm.DB, error) {
	db, err := gorm.Open(mysql.Open(cfg.DatabaseDSN), &gorm.Config{})
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
