package main

import (
	"context"
	"encoding/json"
	"math/rand"
	"net/http"

	"service/types"
	// "github.com/anthdm/pricefetcher/types"
)

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
	http.HandleFunc("/", makeHTTPHandlerFunc(s.handleFetchPrice))
	http.ListenAndServe(s.listenAddr, nil)
}

func makeHTTPHandlerFunc(apiFn APIFunc) http.HandlerFunc {
	ctx := context.Background()
	ctx = context.WithValue(ctx, "requestID", rand.Intn(10000000))

	return func(w http.ResponseWriter, r *http.Request) {
		if err := apiFn(ctx, w, r); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]any{"error": err.Error()})
		}
	}
}

func (s *JSONAPIServer) handleFetchPrice(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
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
