package main

import (
	"context"
)

// OrderPlacer interface  
type OrderPlacer interface {
	PlaceOrder(context.Context, *Order) error
}

// orderPlacerService implements the OrderPlacer interface
type orderPlacerService struct{}

func (s *orderPlacerService) PlaceOrder(ctx context.Context, order *Order) error {
	//nolint:golint,errcheck
	err := orderProducer.Produce(ctx, order)
	if err != nil {
		return err
	}

	return nil
}
