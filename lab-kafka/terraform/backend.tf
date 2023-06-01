terraform {
  backend "s3" {
    bucket = "aws-lab-kafka-tf-state"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
