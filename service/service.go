package main

import (
	"context"
	"fmt"
)

// OrderPlacer interface  
type OrderPlacer interface {
	PlaceOrder(context.Context, *Order) error
}

// orderPlacerService implements the OrderPlacer interface
type orderPlacerService struct{}

type oderPlaceError struct {
	Err error
}

func (e oderPlaceError) Error() string {
	return fmt.Sprintf("order not placed: %v", e.Err)
}

func (s *orderPlacerService) PlaceOrder(ctx context.Context, order *Order) error {
	// nolint:golint,errcheck
	err := orderProducer.Produce(ctx, order)
	if err != nil {
		return oderPlaceError{Err: err}
	}

	return nil
}
