package main

import (
	"context"
	"fmt"
)

type metricsService struct {
	next OrderPlacer
}

func NewMetricsService(next OrderPlacer) OrderPlacer {
	return &metricsService{next}
}

func (s *metricsService) PlaceOrder(ctx context.Context, order *Order) (err error) {
	// your metrics storage. E.g.push to prometheus (gauge, counters)
	fmt.Println("pushing metrics to prometheus")

	return s.next.PlaceOrder(ctx, order)
}
