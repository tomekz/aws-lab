data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2
resource "aws_key_pair" "kafka-node-1" {
  key_name   = "kafka-node-1"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "kafka-node-2" {
  key_name   = "kafka-node-2"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "kafka-node-sg" {
  name        = "kafka-node-sg"
  description = "Allow TCP/22"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
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

resource "aws_instance" "kafka-node-1" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.kafka-node-1.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kafka-node-sg.id]
  subnet_id                   = aws_subnet.public_1.id

  tags = {
    Name = "lab-kafka-node-1"
    Role = "kafka-node"
  }
}

resource "aws_instance" "kafka-node-2" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.kafka-node-2.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kafka-node-sg.id]
  subnet_id                   = aws_subnet.public_1.id

  tags = {
    Name = "lab-kafka-node-2"
    Role = "kafka-node"
  }
}

