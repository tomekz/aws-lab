variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "cluster_endpoint_public_access" {
  description = "Whether to publicly expose the cluster API"
  type        = bool
}

variable "vpc_id" {
  description = "ID of VPC where EC2 jumphost will be deployed"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "EKS VPC CIDR"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of IDs of possible subnets to deploy EC2 jumphost"
  type        = list(string)
  default     = []
}

variable "cluster_admin_arn" {
  description = "ARN of an IAM role (or EC2 instance profile) that will manage the EKS cluster"
  type        = string
  default     = ""
}
