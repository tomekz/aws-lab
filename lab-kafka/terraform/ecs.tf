resource "aws_ecs_cluster" "lab_kafka_ecs_cluster" {
  name = "lab-kafka-ecs-cluster"
  tags = merge(local.tags, { "Name" = "lab-kafka-ecs-cluster" })
}


resource "aws_cloudwatch_log_group" "log-group" {
  name = "lab-kafka-ecs-service-logs"
  tags = merge(local.tags, { "Name" = "lab-kafka-ecs-service-logs" })
}
