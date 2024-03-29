data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "bastion-host-key-pair" {
  key_name   = "bastion-host"
  public_key = var.public_key
}

resource "aws_iam_role" "cloudwatch_logs_role" {
  name = "ec2-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.cloudwatch_logs_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.cloudwatch_logs_role.name
}

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
    description     = "Allow ssh from the bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-host-sg.id]
  }
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
    security_groups = [aws_security_group.bastion-host-sg.id]

  }
  ingress {
    description = "Allow 9092 from specified CIRD range"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["10.0.2.0/24"]
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  user_data                   = <<-EOF
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  user_data                   = <<-EOF
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  user_data                   = <<-EOF
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
