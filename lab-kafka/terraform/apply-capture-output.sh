#!/bin/bash
# This script is used to call terraform apply and capture the output and write the values to a .env file
# *** This script is called from the Makefile ***

terraform_output=$(make apply-tf)

echo "Capturing values from Terraform output..."
echo $terraform_output

# Extract the output values
kafka_node_1_public_ip=$(echo "$terraform_output" | awk '/kafka-node-1-public-ip/ {getline; print}' | awk '{print $3}')
kafka_node_1_private_ip=$(echo "$terraform_output" | awk '/kafka-node-1-private-ip/ {getline; print}' | awk '{print $3}')
kafka_node_2_public_ip=$(echo "$terraform_output" | awk '/kafka-node-2-public-ip/ {getline; print}' | awk '{print $3}')
kafka_node_2_private_ip=$(echo "$terraform_output" | awk '/kafka-node-2-private-ip/ {getline; print}' | awk '{print $3}')

# Write the values to .env file
echo "KAFKA_NODE_1_PUBLIC_IP=$kafka_node_1_public_ip" > ../ansible-playbooks/.env
echo "KAFKA_NODE_1_PRIVATE_IP=$kafka_node_1_private_ip" >> ../ansible-playbooks/.env
echo "KAFKA_NODE_2_PUBLIC_IP=$kafka_node_2_public_ip" >> ../ansible-playbooks/.env
echo "KAFKA_NODE_2_PRIVATE_IP=$kafka_node_2_private_ip" >> ../ansible-playbooks/.env
#
echo "Values captured and written to `../ansible-playbooks/.env` file."
