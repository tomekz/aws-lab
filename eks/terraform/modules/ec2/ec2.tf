resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.this.name
}

resource "random_shuffle" "shuffle" {
  input        = var.subnet_ids
  result_count = 1
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = one(random_shuffle.shuffle.result)

  vpc_security_group_ids = [aws_security_group.this.id]

  iam_instance_profile = aws_iam_instance_profile.this.name
  user_data_base64     = var.cloud_init

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.name
  }
}
