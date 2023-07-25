package main

import (
	"context"
	"fmt"
	"time"

	"service/types"
)

// HelloService is an interface that can respond with "hello (%s)"
type HelloService interface {
	Hello(context.Context, string) (string, error)
	PlaceOrder(context.Context, types.Order) error
}

// helloService implements the HelloService interface
type helloService struct{}

var names = map[string]string{
	"tomekz": "",
}

func (s *helloService) PlaceOrder(ctx context.Context, order types.Order) error {
	// mimic the HTTP roundtrip
	time.Sleep(time.Second * 10)

	fmt.Printf("order: %+v\n", order)
	//nolint:golint,errcheck
	err := OProducer.Produce(ctx, &order)
	if err != nil {
		return err
	}

	return nil
}

func (s *helloService) Hello(ctx context.Context, name string) (string, error) {
	val, ok := names[name]
	if !ok {
		return fmt.Sprintf("hello ( %s )", name), nil
	}

	return fmt.Sprintf("hello ( %s )", val), nil
}
