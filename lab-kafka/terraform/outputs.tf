output "kafka-node-1-public-ip" {
  value = aws_instance.kafka-node-1.public_ip
}

output "kafka-node-2-public-ip" {
  value = aws_instance.kafka-node-2.public_ip
}
