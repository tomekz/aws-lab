package main

import (
	"context"
	"fmt"

	"service/types"
)

type metricsService struct {
	next HelloService
}

func NewMetricsService(next HelloService) HelloService {
	return &metricsService{next}
}

func (s *metricsService) Hello(ctx context.Context, name string) (greeting string, err error) {
	// your metrics storage. E.g.push to prometheus (gauge, counters)
	fmt.Println("pushing metrics to prometheus")

	return s.next.Hello(ctx, name)
}

func (s *metricsService) PlaceOrder(ctx context.Context, order types.Order) (err error) {
	// your metrics storage. E.g.push to prometheus (gauge, counters)
	fmt.Println("pushing metrics to prometheus")

	return s.next.PlaceOrder(ctx, order)
}
