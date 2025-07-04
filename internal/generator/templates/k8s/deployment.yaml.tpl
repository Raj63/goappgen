apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Name }}
  labels:
    app: {{ .Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Name }}
  template:
    metadata:
      labels:
        app: {{ .Name }}
    spec:
      containers:
        - name: {{ .Name }}
          image: {{ .Name }}:latest
          ports:
            - containerPort: 8080
            {{- if .Transport.GRPC }}
            - containerPort: 9090
            {{- end }}
            {{- if eq .Observability.Metrics "prometheus" }}
            - containerPort: 2112
            {{- end }}
          env:
            - name: HTTP_PORT
              value: "8080"
            - name: GRPC_PORT
              value: "9090"
            - name: DATABASE_DSN
              valueFrom:
                secretKeyRef:
                  name: {{ .Name }}-secrets
                  key: database_dsn
            # Add more envs as needed
