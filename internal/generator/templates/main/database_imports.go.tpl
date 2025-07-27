// Database imports go here
{{- if eq .Database.ORM "gorm" }}
    "gorm.io/gorm"
    {{- if eq .Database.Type "postgres" }}
    "gorm.io/driver/postgres"
    {{- else if eq .Database.Type "sqlite" }}
    "gorm.io/driver/sqlite"
    {{- else if or (eq .Database.Type "mysql") (eq .Database.Type "mariadb") }}
    "gorm.io/driver/mysql"
    {{- end }}
{{- else if and (eq .Database.ORM "pgx") (eq .Database.Type "postgres") }}
    "github.com/jackc/pgx/v5"
{{- else if eq .Database.ORM "sqlc" }}
    "database/sql"
    {{- if eq .Database.Type "postgres" }}
    _ "github.com/lib/pq"
    {{- else if eq .Database.Type "mysql" }}
    _ "github.com/go-sql-driver/mysql"
    {{- else if eq .Database.Type "sqlite" }}
    _ "github.com/mattn/go-sqlite3"
    {{- end }}
{{- end }}
{{- if eq .Database.Type "mongo" }}
    "go.mongodb.org/mongo-driver/mongo"
    "go.mongodb.org/mongo-driver/mongo/options"
{{- end }}
