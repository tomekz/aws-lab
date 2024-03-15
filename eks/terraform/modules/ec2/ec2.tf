data "aws_iam_policy_document" "this" {
  statement {
    sid = "AssumeRolePolicyDocument"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "eks" {
  statement {
    sid = "EKSAdminPolicy"

    actions = ["eks:*"]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "S3Download"

    actions = [
      "s3:GetObject",
      "s3:GetObjectLocation",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::bp-istio-game-day-00x",
      "arn:aws:s3:::bp-istio-game-day-00x/*"
    ]
  }
}


resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = module.iam.name
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
