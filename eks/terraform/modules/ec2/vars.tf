variable "name" {
  description = "EC2 jumphost name"
  type        = string
  default     = ""
}

variable "cloud_init" {
  description = "Cloud-init as base64 encoded string"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID for EC2 jumphost"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of VPC where EC2 jumphost will be deployed"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR range of VPC where EC2 jumphost will be deployed"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of IDs of possible subnets to deploy EC2 jumphost"
  type        = list(string)
  default     = []
}
