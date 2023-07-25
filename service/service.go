package main

import (
	"context"
	"fmt"
	"time"
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

	//nolint:golint,errcheck
	OProducer.Produce(ctx, &Order{
		OrderID:    "123",
		CustomerID: name,
		Total:      3000,
	})

	val, ok := names[name]
	if !ok {
		return fmt.Sprintf("hello ( %s )", name), nil
	}

	return fmt.Sprintf("hello ( %s )", val), nil
}
