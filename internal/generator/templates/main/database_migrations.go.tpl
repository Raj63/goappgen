{{- if .Database.Migrations }}
	// Run database migrations
	if err := db.RunMigrations(os.Getenv("DATABASE_DSN")); err != nil {
		logger.Error("Failed to run migrations", "error", err)
		return
	}

	// Create migrations directory and example files
	if err := db.CreateMigrationsDir(); err != nil {
		logger.Error("Failed to create migrations directory", "error", err)
	}

	// Run database seeding
	if err := db.RunSeeding(ctx, database); err != nil {
		logger.Error("Failed to seed database", "error", err)
	}

	// Create seed data file
	if err := db.CreateSeedDataFile(); err != nil {
		logger.Error("Failed to create seed data file", "error", err)
	}
{{- end }}
