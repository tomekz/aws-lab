package main

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	orderProducer = &OrderProducer{
		producer: NewProducer(),
		topic:    os.Getenv("KAFKA_TOPIC"),
	}
	defer orderProducer.producer.Close()

	svc := NewLoggingService(NewMetricsService(&orderPlacerService{}))

	server := NewJSONAPIServer(svc)
	server.Run()
}
