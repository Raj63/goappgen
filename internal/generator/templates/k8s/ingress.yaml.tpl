apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Name }}-ingress
spec:
  rules:
    - host: {{ .Name }}.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Name }}
                port:
                  number: 80
