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

	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

type PlaceOrderResponse struct {
	OrderID string `json:"order_id"`
}

type Order struct {
	OrderID    string `json:"order_id"`
	CustomerID string `json:"customer_id"`
	Total      int    `json:"total"`
}

// APIFunc is a custom type for http handler function that supports context param and returns error
type APIFunc func(context.Context, http.ResponseWriter, *http.Request) error

type JSONAPIServer struct {
	svc        OrderPlacer
	httpServer *http.Server
}

func NewJSONAPIServer(svc OrderPlacer) *JSONAPIServer {
	return &JSONAPIServer{
		svc: svc,
		httpServer: &http.Server{
			Addr:         os.Getenv("HTTP_SERVER_LISTEN_ADDRESS"),
			ReadTimeout:  5 * time.Second,
			WriteTimeout: 5 * time.Second,
		},
	}
}

func (s *JSONAPIServer) Run() {
	rMux := mux.NewRouter()
	rMux.NotFoundHandler = http.HandlerFunc(DefaultHandler)

	rMux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("Health check: OK")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "Health check: OK")
	})

	postMux := rMux.Methods(http.MethodPost).Subrouter()
	postMux.HandleFunc("/order", makeHTTPHandlerFunc(s.placeOrder))

	s.httpServer.Handler = rMux

	go func() {
		log.Println("Server is running on", os.Getenv("HTTP_SERVER_LISTEN_ADDRESS"))
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
	return func(w http.ResponseWriter, r *http.Request) {
		//nolint:errcheck,staticcheck
		ctx, _ := context.WithTimeout(r.Context(), 5*time.Second)

		//nolint:staticcheck
		ctx = context.WithValue(ctx, "requestID", rand.Intn(10000000))
		// defer cancel()
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
	order := &Order{}
	if err := json.NewDecoder(r.Body).Decode(order); err != nil {
		return err
	}

	err := s.svc.PlaceOrder(ctx, order)
	if err != nil {
		fmt.Println("Error placing order:", err)
		return writeJSON(w, http.StatusInternalServerError, map[string]any{"error": err.Error()})
	}

	priceResp := PlaceOrderResponse{
		OrderID: uuid.New().String(),
	}

	return writeJSON(w, http.StatusOK, &priceResp)
}

func writeJSON(w http.ResponseWriter, s int, v any) error {
	w.WriteHeader(s)
	return json.NewEncoder(w).Encode(v)
}
