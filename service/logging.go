package main

import (
	"context"
	"time"

	"github.com/sirupsen/logrus"
)

type loggingService struct {
	next OrderPlacer
}

func NewLoggingService(next OrderPlacer) OrderPlacer {
	return &loggingService{next}
}

func (s *loggingService) PlaceOrder(ctx context.Context, order *Order) (err error) {
	// your metrics storage. E.g.push to prometheus (gauge, counters)
	defer func(begin time.Time) {
		logrus.WithFields(logrus.Fields{
			"requestID": ctx.Value("requestID"),
			"took":      time.Since(begin),
			"err":       err,
			"order":     order,
		}).Info("placeOrder")
	}(time.Now())

	return s.next.PlaceOrder(ctx, order)
}
