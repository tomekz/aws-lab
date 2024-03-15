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


resource "aws_iam_role" "this" {
  name               = "${var.name}-role"
  path               = "/"
  description        = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.this.json

}

resource "aws_iam_policy" "eks-policy" {
  name        = "${var.name}-eks-policy"
  path        = "/"
  description = "${var.name} EKS policy"

  policy = data.aws_iam_policy_document.eks.json
}

resource "aws_iam_policy" "s3-policy" {
  name        = "${var.name}-s3-policy"
  path        = "/"
  description = "${var.name} S3 policy"

  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "eks-policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.eks-policy.arn
}

resource "aws_iam_role_policy_attachment" "s3-policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3-policy.arn
}
