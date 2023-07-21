resource "aws_ecr_repository" "lab_kafka_ecr_repository" {
  name                 = "lab-kafka-ecr"
  image_tag_mutability = "MUTABLE"
  tags              = merge(local.tags, { "Name" = "lab-kafka-ecr" })
}
