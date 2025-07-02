package main

import (
	"log"
	"net/http"
)

func main() {
	log.Println("{{.Name}} starting...")

	{{ if .HTTP }}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello from {{.Name}}"))
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
	{{ else }}
	log.Println("No HTTP server configured")
	{{ end }}
}
