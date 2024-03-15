#cloud-config

packages:
  - git

runcmd:
- echo ${hello} 
