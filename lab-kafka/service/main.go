package main

import (
	"flag"
	"fmt"
)

func main() {
	listenAddr := flag.String("listenaddr", ":3000", "listen address the service is running")
	flag.Parse()

	svc := NewLoggingService(NewMetricsService(&helloService{}))

	server := NewJSONAPIServer(*listenAddr, svc)
	server.Run()
	fmt.Println("Server is running on", *listenAddr)
}
