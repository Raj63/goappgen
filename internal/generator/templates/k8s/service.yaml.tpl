apiVersion: v1
kind: Service
metadata:
  name: {{ .Name }}
spec:
  selector:
    app: {{ .Name }}
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
    {{- if .Transport.GRPC }}
    - protocol: TCP
      port: 9090
      targetPort: 9090
    {{- end }}
    {{- if eq .Observability.Metrics.Type "prometheus" }}
    - protocol: TCP
      port: 2112
      targetPort: 2112
    {{- end }}
