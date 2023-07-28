package main

import (
	"log"

	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	producer := NewOrderProducer()
	defer producer.producer.Close()

	svc := NewLoggingService(NewMetricsService(&orderPlacerService{}))

	server := NewJSONAPIServer(svc)
	server.Run()
}
