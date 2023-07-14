resource "aws_ecr_repository" "my_ecr_repository" {
  name                 = "lab-kafka-ecr"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "lab-kafka-ecr"
  }
}
