version: '3.8'

services:
{{- if eq (len .App) 1 }}
  app:
    build: .
    container_name: {{ (index .App 0).Name }}
    environment:
      - HTTP_PORT=8080
      - GRPC_PORT=9090
      - DATABASE_DSN=${DATABASE_DSN}
      - MONGO_URI=${MONGO_URI}
      - JWT_SECRET=${JWT_SECRET}
      - METRICS_PORT=2112
    ports:
      - "8080:8080"
      - "9090:9090"
      - "2112:2112"
    depends_on:
      {{- if eq (index .App 0).Database.Type "postgres" }}
      - db
      {{- else if or (eq (index .App 0).Database.Type "mysql") (eq (index .App 0).Database.Type "mariadb") }}
      - db
      {{- else if eq (index .App 0).Database.Type "mongo" }}
      - mongo
      {{- end }}
      {{- if eq (index .App 0).Observability.Metrics "prometheus" }}
      - prometheus
      {{- end }}
      {{- if or (eq (index .App 0).Storage.Type "s3") (eq (index .App 0).Storage.Type "minio") }}
      - minio
      {{- end }}
    {{- if (index .App 0).DevTools.Air }}
    command: ["air", "-c", "air.toml"]
    volumes:
      - ./:/app
    {{- end }}
{{- else }}
{{- range $i, $app := .App }}
  {{ $app.Name }}:
    build:
      context: ./apps/{{ $app.Name }}
      dockerfile: Dockerfile
    container_name: {{ $app.Name }}
    environment:
      - HTTP_PORT=8080
      - GRPC_PORT=9090
      - DATABASE_DSN=${DATABASE_DSN}
      - MONGO_URI=${MONGO_URI}
      - JWT_SECRET=${JWT_SECRET}
      - METRICS_PORT=2112
    ports:
      - "{{ add 8080 $i }}:8080"
      - "{{ add 9090 $i }}:9090"
      - "{{ add 2112 $i }}:2112"
    depends_on:
      {{- if eq $app.Database.Type "postgres" }}
      - db
      {{- else if or (eq $app.Database.Type "mysql") (eq $app.Database.Type "mariadb") }}
      - db
      {{- else if eq $app.Database.Type "mongo" }}
      - mongo
      {{- end }}
      {{- if eq $app.Observability.Metrics "prometheus" }}
      - prometheus
      {{- end }}
      {{- if or (eq $app.Storage.Type "s3") (eq $app.Storage.Type "minio") }}
      - minio
      {{- end }}
    {{- if $app.DevTools.Air }}
    command: ["air", "-c", "air.toml"]
    volumes:
      - ./apps/{{ $app.Name }}:/app
    {{- end }}
{{- end }}
{{- end }}

# Shared services
{{- $firstApp := index .App 0 }}
{{- if eq $firstApp.Database.Type "postgres" }}
db:
  image: postgres:15
  restart: always
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: pass
    POSTGRES_DB: dbname
  ports:
    - "5432:5432"
  volumes:
    - pgdata:/var/lib/postgresql/data
{{- else if or (eq $firstApp.Database.Type "mysql") (eq $firstApp.Database.Type "mariadb") }}
db:
  image: mysql:8
  restart: always
  environment:
    MYSQL_ROOT_PASSWORD: pass
    MYSQL_DATABASE: dbname
    MYSQL_USER: user
    MYSQL_PASSWORD: pass
  ports:
    - "3306:3306"
  volumes:
    - mysqldata:/var/lib/mysql
{{- else if eq $firstApp.Database.Type "mongo" }}
mongo:
  image: mongo:6
  restart: always
  environment:
    MONGO_INITDB_ROOT_USERNAME: user
    MONGO_INITDB_ROOT_PASSWORD: pass
  ports:
    - "27017:27017"
  volumes:
    - mongodata:/data/db
{{- end }}

{{- if eq $firstApp.Observability.Metrics "prometheus" }}
prometheus:
  image: prom/prometheus:latest
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml
  ports:
    - "9091:9090"
{{- end }}

{{- if or (eq $firstApp.Storage.Type "s3") (eq $firstApp.Storage.Type "minio") }}
minio:
  image: minio/minio:latest
  environment:
    MINIO_ROOT_USER: {{ default "minio" $firstApp.Storage.AccessKey }}
    MINIO_ROOT_PASSWORD: {{ default "minio123" $firstApp.Storage.SecretKey }}
  command: server /data
  ports:
    - "9000:9000"
    - "9001:9001"
  volumes:
    - miniodata:/data
{{- end }}

volumes:
  pgdata:
  mysqldata:
  mongodata:
  miniodata:
