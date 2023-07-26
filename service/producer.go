package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

// global order producer to be used by main.go
var orderProducer *OrderProducer

// Create new kafka producer  
func NewProducer() *kafka.Producer {
	p, err := kafka.NewProducer(&kafka.ConfigMap{
		"bootstrap.servers": os.Getenv("KAFKA_BOOTSTRAP_SERVERS"),
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

func (p *OrderProducer) Produce(ctx context.Context, order *Order) error {
	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}

	//nolint:golint,errcheck
	p.producer.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{Topic: &p.topic, Partition: kafka.PartitionAny},
		Value:          orderJSON,
	}, nil)

	// TODO: handle erros and context cancellation
	// select {
	// case ev := <-p.producer.Events():
	// 	switch e := ev.(type) {
	// 	case *kafka.Message:
	// 		if e.TopicPartition.Error != nil {
	// 			fmt.Printf("Delivery failed: %v\n", e.TopicPartition)
	// 			return e.TopicPartition.Error
	// 		} else {
	// 			fmt.Printf("Delivered message to %v\n", e.TopicPartition)
	// 		}
	// 	}
	// case <-ctx.Done():
	// 	fmt.Println("Context done")
	// }

	return nil
}
