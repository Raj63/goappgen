# Example config.yaml generated for {{ .Name }}

http_port: 8080
{{- if .Transport.GRPC }}
grpc_port: 9090
{{- end }}

{{- if ne .Database.Type "" }}
database_dsn: "{{ if eq .Database.Type "postgres" }}postgres://user:pass@db:5432/dbname?sslmode=disable{{ else if eq .Database.Type "mysql" }}user:pass@tcp(db:3306)/dbname{{ else if eq .Database.Type "sqlite" }}file:test.db{{ else if eq .Database.Type "mongo" }}mongodb://user:pass@mongo:27017{{ end }}"
{{- end }}
{{- if eq .Database.Type "mongo" }}
mongo_uri: "mongodb://user:pass@mongo:27017"
{{- end }}

# Connection Pooling
{{- if ne .Database.Type "" }}
db_max_open_conns: 10
db_max_idle_conns: 5
db_conn_max_lifetime: "1h"
{{- end }}

# JWT Auth
{{- if eq .Auth.Type "jwt" }}
jwt_secret: "supersecret"
{{- end }}

# S3/MinIO Storage
{{- if or (eq .Storage.Type "s3") (eq .Storage.Type "minio") }}
s3_endpoint: "http://minio:9000"
s3_access_key: "minio"
s3_secret_key: "minio123"
s3_region: "us-east-1"
s3_use_ssl: false
{{- end }}

# Observability
{{- if eq .Observability.Metrics "prometheus" }}
metrics_port: 2112
{{- end }} 