package main

import (
	"fmt"
	"log"
	"os"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

// Create new kafka producer  
func NewProducer() *kafka.Producer {
	bootstrapServers, ok := os.LookupEnv("KAFKA_BOOTSTRAP_SERVERS")
	if !ok {
		bootstrapServers = "localhost:9093"
	}

	p, err := kafka.NewProducer(&kafka.ConfigMap{
		"bootstrap.servers": bootstrapServers,
	})
	if err != nil {
		log.Fatalf("Failed to create producer: %s\n", err)
	}

	// Delivery report handler for produced messages
	go func() {
		for e := range p.Events() {
			switch ev := e.(type) {
			case *kafka.Message:
				if ev.TopicPartition.Error != nil {
					fmt.Printf("Delivery failed: %v\n", ev.TopicPartition)
				} else {
					fmt.Printf("Delivered message to %v\n", ev.TopicPartition)
				}
			}
		}
	}()

	fmt.Printf("Producer created %v\n", p)

	return p
}

var Producer = NewProducer()
