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
		"bootstrap.servers":   os.Getenv("KAFKA_BOOTSTRAP_SERVERS"),
		"go.delivery.reports": true,
	})
	if err != nil {
		log.Fatalf("Failed to create producer: %s\n", err)
	}

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

	deliveryChan := make(chan kafka.Event)

	err = p.producer.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{Topic: &p.topic, Partition: kafka.PartitionAny},
		Value:          orderJSON,
	}, deliveryChan)

	if err != nil {
		return err
	}

	select {
	case <-ctx.Done():
		fmt.Printf("Delivery failed: %v\n", ctx.Err())
	case e := <-deliveryChan:
		m := e.(*kafka.Message)

		if m.TopicPartition.Error != nil {
			fmt.Printf("Delivery failed: %v\n", m.TopicPartition.Error)
			return m.TopicPartition.Error
		} else {
			fmt.Printf("Delivered message to %v\n", m.TopicPartition)
		}
	}

	return nil
}
