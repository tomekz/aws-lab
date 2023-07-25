package main

import (
	"context"
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"time"

	"service/types"
)

// APIFunc is a custom type for http handler function that supports context param and returns error
type APIFunc func(context.Context, http.ResponseWriter, *http.Request) error

type JSONAPIServer struct {
	listenAddr string
	svc        HelloService
}

func NewJSONAPIServer(listenAddr string, svc HelloService) *JSONAPIServer {
	return &JSONAPIServer{
		listenAddr: listenAddr,
		svc:        svc,
	}
}

func (s *JSONAPIServer) Run() {
	http.HandleFunc("/", makeHTTPHandlerFunc(s.handleHello))
	log.Println("Server is running on", s.listenAddr)

	if err := http.ListenAndServe(s.listenAddr, nil); err != nil {
		log.Fatalf("failed to listen and serve: %v", err)
	}
}

func makeHTTPHandlerFunc(apiFn APIFunc) http.HandlerFunc {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	ctx = context.WithValue(ctx, "requestID", rand.Intn(10000000))
	defer cancel()

	return func(w http.ResponseWriter, r *http.Request) {
		if err := apiFn(ctx, w, r); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]any{"error": err.Error()})
		}
	}
}

func (s *JSONAPIServer) handleHello(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
	name := r.URL.Query().Get("name")

	greeting, err := s.svc.Hello(ctx, name)
	if err != nil {
		return err
	}

	priceResp := types.HelloResponse{
		Name:     name,
		Greeting: greeting,
	}

	return writeJSON(w, http.StatusOK, &priceResp)
}

func writeJSON(w http.ResponseWriter, s int, v any) error {
	w.WriteHeader(s)
	return json.NewEncoder(w).Encode(v)
}
