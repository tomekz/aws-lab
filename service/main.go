package main

import (
	"fmt"

	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Could not load .env file")
	}

	producer := NewOrderProducer()
	defer producer.producer.Close()

	svc := NewLoggingService(NewMetricsService(&orderPlacerService{}))

	server := NewJSONAPIServer(svc)
	server.Run()
}
