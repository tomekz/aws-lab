package main

import (
	"context"
	"time"

	"github.com/sirupsen/logrus"
)

type loggingService struct {
	next HelloService
}

func NewLoggingService(next HelloService) HelloService {
	return &loggingService{next}
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
