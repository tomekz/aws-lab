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

resource "aws_iam_role_policy_attachment" "eks-policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.eks-policy.arn
}
