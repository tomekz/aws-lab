package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"service/types"

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

type OrderProducer struct {
	producer *kafka.Producer
	topic    string
}

func (p *OrderProducer) Produce(ctx context.Context, order *types.Order) error {
	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}

	//nolint:golint,errcheck
	p.producer.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{Topic: &p.topic, Partition: kafka.PartitionAny},
		Value:          orderJSON,
	}, nil)

	select {
	case ev := <-p.producer.Events():
		switch e := ev.(type) {
		case *kafka.Message:
			if e.TopicPartition.Error != nil {
				fmt.Printf("Delivery failed: %v\n", e.TopicPartition)
				return e.TopicPartition.Error
			} else {
				fmt.Printf("Delivered message to %v\n", e.TopicPartition)
			}
		}
	case <-ctx.Done():
		fmt.Println("Context done")
	}

	return nil
}

// OrderProducer  
var OProducer = &OrderProducer{
	producer: NewProducer(),
	topic:    "orders",
}
