data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "bastion-host-key-pair" {
  key_name   = "bastion-host"
  public_key = var.public_key
}

# resource "null_resource" "copy_ssh_key_to_bastion_host" {
#   provisioner "local-exec" {
#     command = <<EOT
#       scp -o "StrictHostKeyChecking=no" ~/.ssh/id_rsa ec2-user@${aws_instance.bastion-host.public_ip}:/home/ec2-user/.ssh/
#     EOT
#   }
#   depends_on = [aws_instance.bastion-host]
# }

resource "aws_security_group" "bastion-host-sg" {
  name        = "bastion-host-sg"
  description = "Allow TCP/22 from custom IPs"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow 22 from our custom IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kafka-node-sg" {
  name        = "kafka-node-sg"
  description = "Allow TCP/22"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow ssh from the bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion-host-sg.id]
  }
  # this will have to go via load balancer
  # ingress {
  #   description = "Allow 9000 from our public IP"
  #   from_port   = 9000
  #   to_port     = 9000
  #   protocol    = "tcp"
  #   cidr_blocks = [var.external_ip]
  # }
  ingress {
    description = "Allow 3888 between kafka nodes"
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow 2888 between kafka nodes"
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow 2181 between kafka nodes"
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow 9092 between kafka nodes"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    self        = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.bastion-host-key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion-host-sg.id]
  subnet_id                   = aws_subnet.public_1.id

  tags = {
    Name = "lab-kafka-bastion-host"
    Role = "bastion-host"
  }
}

resource "aws_instance" "kafka-node-1" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kafka-node-sg.id]
  subnet_id                   = aws_subnet.private_1.id
  user_data     = <<-EOF
    #!/bin/bash
    echo "${aws_key_pair.bastion-host-key-pair.public_key}" >> /home/ec2-user/.ssh/authorized_keys
    chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
  EOF

  tags = {
    Name = "lab-kafka-node-1"
    Role = "kafka-node"
  }
}

resource "aws_instance" "kafka-node-2" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kafka-node-sg.id]
  subnet_id                   = aws_subnet.private_1.id
  user_data     = <<-EOF
    #!/bin/bash
    echo "${aws_key_pair.bastion-host-key-pair.public_key}" >> /home/ec2-user/.ssh/authorized_keys
    chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
  EOF

  tags = {
    Name = "lab-kafka-node-2"
    Role = "kafka-node"
  }
}

resource "aws_instance" "kafka-node-3" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kafka-node-sg.id]
  subnet_id                   = aws_subnet.private_1.id
  user_data     = <<-EOF
    #!/bin/bash
    echo "${aws_key_pair.bastion-host-key-pair.public_key}" >> /home/ec2-user/.ssh/authorized_keys
    chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
  EOF

  tags = {
    Name = "lab-kafka-node-3"
    Role = "kafka-node"
  }
}
