variable "domain_name" {
  description = "Intermediate Root CA domain name"
  type        = string
  default     = ""
}

variable "alternate_domain_names" {
  description = "(optional) List of alternate domain names for the Intermediate Root CA"
  type        = list(string)
  default     = []
}

variable "ca_private_key" {
  description = "Root CA private key used for signing certificates"
  type        = string
  default     = ""
}

variable "ca_cert" {
  description = "Root CA certificate"
  type        = string
  default     = ""
}
