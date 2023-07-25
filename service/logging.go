package main

import (
	"context"
	"time"

	"service/types"

	"github.com/sirupsen/logrus"
)

type loggingService struct {
	next HelloService
}

func NewLoggingService(next HelloService) HelloService {
	return &loggingService{next}
}

func (s *loggingService) PlaceOrder(ctx context.Context, order types.Order) (err error) {
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

func (s *loggingService) Hello(ctx context.Context, name string) (greeting string, err error) {
	defer func(begin time.Time) {
		logrus.WithFields(logrus.Fields{
			"requestID": ctx.Value("requestID"),
			"took":      time.Since(begin),
			"err":       err,
			"greeting":  greeting,
		}).Info("hello")
	}(time.Now())

	return s.next.Hello(ctx, name)
}
