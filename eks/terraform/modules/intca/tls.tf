resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "tls_cert_request" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  dns_names = concat([var.domain_name], var.alternate_domain_names)

  subject {
    common_name  = var.domain_name
    organization = "${var.domain_name} inc"
  }
}

resource "tls_locally_signed_cert" "this" {
  cert_request_pem   = tls_cert_request.this.cert_request_pem
  ca_private_key_pem = var.ca_private_key
  ca_cert_pem        = var.ca_cert

  validity_period_hours = 8766

  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "content_commitment",
    "code_signing",
    "cert_signing",
  ]
}

# UNCOMMENT IF YOU WISH TO USE PUBLIC KUBERNETES API
#
# resource "null_resource" "pkey" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "${tls_private_key.this.private_key_pem}" > intca_pkey.pem && chmod 400 intca_pkey.pem
#     EOT
#   }
# }

# resource "null_resource" "csr" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "${tls_cert_request.this.cert_request_pem}" > intca_csr.pem && chmod 400 intca_csr.pem
#     EOT
#   }
# }

# resource "null_resource" "cert" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "${tls_locally_signed_cert.this.cert_pem}" > intca.pem && chmod 444 intca.pem
#     EOT
#   }
# }
