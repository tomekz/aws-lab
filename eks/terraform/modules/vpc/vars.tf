variable "name" {
  description = "VPC name"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR prefix (4 octets before the trailing slash)"
  type        = string
  default     = ""
}

variable "clusters" {
  description = "List of EKS cluster names that are deployed to this VPC"
  type        = list(string)
  default     = []
}
