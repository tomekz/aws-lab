provider "aws" {
  region = "us-west-2"  # Replace with your desired AWS region
}

resource "aws_ecr_repository" "my_ecr_repository" {
  name                 = "my-ecr-repo"  # Replace with your desired repository name
  image_tag_mutability = "MUTABLE"      # Optional: Specify the image tag mutability (default is MUTABLE)
  tags = {
    Name = "lab-kafka-ecr"
  }
}

