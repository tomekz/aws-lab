package main

import (
	"context"
	"fmt"
	"time"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

// HelloService is an interface that can respond with "hello (%s)"
type HelloService interface {
	Hello(context.Context, string) (string, error)
}

// helloService implements the HelloService interface
type helloService struct{}

var names = map[string]string{
	"tomekz": "",
}

func (s *helloService) Hello(ctx context.Context, name string) (string, error) {
	// mimic the HTTP roundtrip
	time.Sleep(time.Second * 1)

	topic := "foo"

	//nolint:golint,errcheck
	Producer.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Value:          []byte("Hello from service.go"),
	}, nil)

	val, ok := names[name]
	if !ok {
		return fmt.Sprintf("hello ( %s )", name), nil
	}

	return fmt.Sprintf("hello ( %s )", val), nil
}
