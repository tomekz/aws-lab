terraform {
  backend "s3" {
    bucket = "aws-lab-tf-state"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
