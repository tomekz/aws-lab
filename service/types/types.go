package types

type HelloResponse struct {
	Name     string `json:"name"`
	Greeting string `json:"greeting"`
}

type PlaceOrderResponse struct {
	Status string `json:"status"`
}

type Order struct {
	OrderID    string `json:"order_id"`
	CustomerID string `json:"customer_id"`
	Total      int    `json:"total"`
}
