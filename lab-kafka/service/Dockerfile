FROM golang as builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o helloservice .

FROM scratch
COPY --from=builder /app/helloservice /
CMD ["/helloservice"]
