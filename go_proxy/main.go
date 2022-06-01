package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"time"
)

var (
	targetUrl *url.URL
)

func main() {
	var err error
	targetUrl, err = url.Parse("http://localhost:8080")
	if err != nil {
		panic(err)
	}

	handler := http.NewServeMux()
	handler.HandleFunc("/", proxyHandler)

	server := &http.Server{
		Addr:         ":1443",
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  15 * time.Second,
	}
	log.Printf("Listening on %s\n", server.Addr)
	log.Fatal(server.ListenAndServeTLS("self_signed_certs/cert.pem", "self_signed_certs/key.pem"))
}

func proxyHandler(writer http.ResponseWriter, request *http.Request) {
	httputil.NewSingleHostReverseProxy(targetUrl).ServeHTTP(writer, request)
}
