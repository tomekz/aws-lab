package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"time"

	"service/types"

	"github.com/gorilla/mux"
)

// APIFunc is a custom type for http handler function that supports context param and returns error
type APIFunc func(context.Context, http.ResponseWriter, *http.Request) error

type JSONAPIServer struct {
	listenAddr string
	svc        HelloService
	httpServer *http.Server
}

func NewJSONAPIServer(listenAddr string, svc HelloService) *JSONAPIServer {
	return &JSONAPIServer{
		listenAddr: listenAddr,
		svc:        svc,
		httpServer: &http.Server{
			Addr:         listenAddr,
			ReadTimeout:  5 * time.Second,
			WriteTimeout: 5 * time.Second,
		},
	}
}

func (s *JSONAPIServer) Run() {
	rMux := mux.NewRouter()
	rMux.NotFoundHandler = http.HandlerFunc(DefaultHandler)

	// mux := http.NewServeMux()
	rMux.HandleFunc("/hello", makeHTTPHandlerFunc(s.handleHello))

	postMux := rMux.Methods(http.MethodPost).Subrouter()
	postMux.HandleFunc("/order", makeHTTPHandlerFunc(s.placeOrder))

	s.httpServer.Handler = rMux

	go func() {
		log.Println("Server is running on", s.listenAddr)
		if err := s.httpServer.ListenAndServe(); err != nil {
			log.Fatalf("failed to listen and serve: %v", err)
		}
	}()

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt)
	sig := <-sigs
	log.Println("Shutting down the server after signal", sig)
	//nolint:errcheck,staticcheck
	s.httpServer.Shutdown(nil)
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

func DefaultHandler(rw http.ResponseWriter, r *http.Request) {
	log.Println("DefaultHandler Serving:", r.URL.Path, "from", r.Host, "with method", r.Method)
	rw.WriteHeader(http.StatusNotFound)
	Body := r.URL.Path + " is not supported. Thanks for visiting!\n"
	fmt.Fprintf(rw, "%s", Body)
}

func (s *JSONAPIServer) placeOrder(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
	order := types.Order{}
	if err := json.NewDecoder(r.Body).Decode(&order); err != nil {
		return err
	}

	err := s.svc.PlaceOrder(ctx, order)
	if err != nil {
		return err
	}

	priceResp := types.PlaceOrderResponse{
		Status: "OK", // TODO: add more meaningful status
	}

	return writeJSON(w, http.StatusOK, &priceResp)
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
