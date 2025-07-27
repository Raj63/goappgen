// Database setup code goes here
{{- if eq .Database.ORM "gorm" }}
var database *gorm.DB
var err error
{{- if eq .Database.Type "postgres" }}
database, err = gorm.Open(postgres.Open(os.Getenv("DATABASE_DSN")), &gorm.Config{})
{{- else if eq .Database.Type "sqlite" }}
database, err = gorm.Open(sqlite.Open(os.Getenv("DATABASE_DSN")), &gorm.Config{})
{{- else if or (eq .Database.Type "mysql") (eq .Database.Type "mariadb") }}
database, err = gorm.Open(mysql.Open(os.Getenv("DATABASE_DSN")), &gorm.Config{})
{{- end }}
if err != nil {
    logger.Error("Failed to connect to database", "error", err)
    return
}
{{- else if and (eq .Database.ORM "pgx") (eq .Database.Type "postgres") }}
database, err := pgx.Connect(ctx, os.Getenv("DATABASE_DSN"))
if err != nil {
    logger.Error("Failed to connect to database", "error", err)
    return
}
{{- else if eq .Database.ORM "sqlc" }}
database, err := sql.Open("{{ .Database.Type }}", os.Getenv("DATABASE_DSN"))
if err != nil {
    logger.Error("Failed to connect to database", "error", err)
    return
}
{{- end }}
{{- if eq .Database.Type "mongo" }}
mongoClient, err := mongo.Connect(ctx, options.Client().ApplyURI(os.Getenv("MONGO_URI")))
if err != nil {
    logger.Error("Failed to connect to MongoDB", "error", err)
    return
}
database := mongoClient
{{- end }}
