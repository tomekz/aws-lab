output "csr_pem" {
  value = tls_cert_request.this.cert_request_pem
}

output "public_key_pem" {
  value = tls_private_key.this.public_key_pem
}

output "private_key_pem" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}

output "ca_cert_pem" {
  value = tls_locally_signed_cert.this.cert_pem
}
