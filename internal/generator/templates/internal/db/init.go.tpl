package db

{{- if and (eq .Database.ORM "gorm") (eq .Database.Type "postgres") }}
{{ include "init_postgres_gorm.go.tpl" }}
{{- else if and (eq .Database.ORM "gorm") (eq .Database.Type "sqlite") }}
{{ include "init_sqlite_gorm.go.tpl" }}
{{- else if and (eq .Database.ORM "gorm") (or (eq .Database.Type "mysql") (eq .Database.Type "mariadb")) }}
{{ include "init_mysql_gorm.go.tpl" }}
{{- else if and (eq .Database.ORM "pgx") (eq .Database.Type "postgres") }}
{{ include "init_postgres_pgx.go.tpl" }}
{{- else if and (eq .Database.ORM "sqlc") (eq .Database.Type "postgres") }}
{{ include "init_postgres_sqlc.go.tpl" }}
{{- else if and (eq .Database.ORM "sqlc") (or (eq .Database.Type "mysql") (eq .Database.Type "mariadb")) }}
{{ include "init_mysql_sqlc.go.tpl" }}
{{- else if and (eq .Database.ORM "sqlc") (eq .Database.Type "sqlite") }}
{{ include "init_sqlite_sqlc.go.tpl" }}
{{- else if eq .Database.Type "mongo" }}
{{ include "init_mongo.go.tpl" }}
{{- else if and (not .Database.ORM) (eq .Database.Type "postgres") }}
{{ include "init_postgres_noorm.go.tpl" }}
{{- else if and (not .Database.ORM) (or (eq .Database.Type "mysql") (eq .Database.Type "mariadb")) }}
{{ include "init_mysql_noorm.go.tpl" }}
{{- else if and (not .Database.ORM) (eq .Database.Type "sqlite") }}
{{ include "init_sqlite_noorm.go.tpl" }}
{{- else }}
// No supported database type/ORM selected
{{- end }}
