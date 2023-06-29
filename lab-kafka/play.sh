#!/bin/bash
echo "Running Ansible ping command..."
ansible_ping_output=$(ansible all -m ping 2>&1)

if [[ $ansible_ping_output == *"SUCCESS"* ]]; then
    echo "Ansible ping command succeeded."
else
    echo "Ansible ping command failed."
    echo "$ansible_ping_output" >&2
    exit 1
fi

echo "installing docker"
ansible-playbook ansible-playbooks/docker.yaml

echo "installing kafka cluster"
for node_number in 1 2 3; do
    echo "Running Ansible playbook: $node_number"

    # Execute Ansible playbook and capture the output
    output=$(ansible-playbook ansible-playbooks/kafka-setup.yaml --extra-vars "node_number=$node_number" 2>&1)
    exit_code=$?
    
    # Check the exit code to determine if the Ansible command succeeded
    if [ $exit_code -eq 0 ]; then
        echo "Ansible playbook executed successfully."
    else
        echo "Ansible playbook failed with exit code $exit_code"
    fi
    
    # Print the captured output
    echo "Ansible playbook output:"
    echo "$output"
    echo "---------------------------"
done
