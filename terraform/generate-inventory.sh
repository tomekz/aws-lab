#!/bin/bash
# This script runs the Terraform output command to get the IP addresses of the EC2 instances
# and then uses the IP addresses to generate an Ansible inventory file.
# This script is called from the Makefile
#
bastion_host_public_ip=$(terraform output -raw bastion-host-public-ip)
kafka_node_1_private_ip=$(terraform output -raw kafka-node-1-private-ip)
kafka_node_2_private_ip=$(terraform output -raw kafka-node-2-private-ip)
kafka_node_3_private_ip=$(terraform output -raw kafka-node-3-private-ip)


# Define the path to the inventory template file
INVENTORY_TEMPLATE="../ansible-aws-inventory/inventory.ini.template"

# Define the path to the output inventory file
INVENTORY_FILE="../ansible-aws-inventory/inventory.ini"

# Replace placeholder IP values in the template file with Terraform variables
sed -e "s|\${BASTION_HOST_PUBLIC_IP}|$bastion_host_public_ip|g" \
    -e "s|\${KAFKA_NODE_1_PRIVATE_IP}|$kafka_node_1_private_ip|g" \
    -e "s|\${KAFKA_NODE_2_PRIVATE_IP}|$kafka_node_2_private_ip|g" \
    -e "s|\${KAFKA_NODE_3_PRIVATE_IP}|$kafka_node_3_private_ip|g" \
    "$INVENTORY_TEMPLATE" > "$INVENTORY_FILE"

echo "Generated inventory file: $INVENTORY_FILE"

