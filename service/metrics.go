package main

import (
	"context"
	"fmt"
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
