terraform {
  backend "local" {
    path = "state.tfstate"
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Provisioning = "terraform"
      Project      = "lab-eks"
    }
  }
}
