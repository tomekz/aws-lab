#!/bin/bash
# This script runs the Terraform output command and transforms the output into a .env file
# This script is called from the Makefile

# Run Terraform output command and capture the result
output=$(terraform output -json)

# Extract the values from the JSON output and format them as uppercase key-value pairs
values=$(echo "$output" | jq -r 'to_entries | map("\(.key | gsub("-"; "_") | ascii_upcase)=\(.value.value)") | .[]')
echo "captured values: $values"
# Save the values into a .env file
echo "$values" > ../ansible-playbooks/.env
