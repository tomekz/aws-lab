# order placer microservice
A microservice for placing orders on crypto exchanges.
- exposes a REST API and client for placing orders
- orders are received by the service and sent to a Kafka topic

## Start the application
start kafka and zookeeper using docker-compose

to start just single kafka broker 

```
docker-compose up 
```

to start kafka cluster with 3 brokers

```
docker-compose --profile clustered up 
```

start the service:
```
make run
```


## Testing kafka with kafkacat

Kafkacat is a command line utility for producing and consuming messages with Apache Kafka.

To produce a message to a topic <topic>:
```
docker run -it --network=host edenhill/kafkacat:1.5.0 -b 0.0.0.0:9093 -P -t <topic>
```

In another terminal, to consume messages from a topic <topic>:
```
docker run -it --network=host edenhill/kafkacat:1.5.0 -b 0.0.0.0:9093 -C -t <topic>
```

## Testing kafka with kafka-ui

If you don't want to use CLI tool, you can use kafka-ui. It is a web interface for kafka cluster management.

Go to http://localhost:8080/

## Testing dockerized microservice on local docker network

build the docker image

```
docker build -t service:<tag> .
```

run kafka cluster and zookeeper

```
docker-compose --profile clustered up 
```

run the service container and connect it to the kafka docker network

```
docker run --network=service_default -p 3000:3000 -e "KAFKA_BOOTSTRAP_SERVERS=kafka1:9092,kafka2:9092,kafka3:9092" service:<tag>
```
