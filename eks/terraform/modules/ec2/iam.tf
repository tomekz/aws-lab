# module "iam" {
#   source  = "app.terraform.io/infrapanda/iam-role/aws"
#   version = "1.0.0"
#
#   name        = "${var.name}-role"
#   description = "${var.name} role"
#   path        = "/"
#
#   assume_role_policy = data.aws_iam_policy_document.this.json
#   policy_arns        = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
#
#   policies = {
#     "eks" = {
#       name        = "${var.name}-eks-policy"
#       description = "${var.name} EKS policy"
#       path        = "/"
#       policy      = data.aws_iam_policy_document.eks.json
#     }
#     "s3" = {
#       name        = "${var.name}-s3-policy"
#       description = "${var.name} S3 policy"
#       path        = "/"
#       policy      = data.aws_iam_policy_document.s3.json
#     }
#   }
# }

resource "aws_iam_role" "this" {
  name                  = var.name
  path                  = var.path
  description           = var.description
  assume_role_policy    = var.assume_role_policy
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary # tflint-ignore: aws_iam_user_invalid_permissions_boundary

  tags = var.tags
}

resource "aws_iam_policy" "internal" {
  for_each = var.policies

  name        = each.value.name
  path        = each.value.path
  description = each.value.description

  policy = each.value.policy
}

resource "aws_iam_role_policy_attachment" "internal" {
  for_each = var.policies

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.internal[each.key].arn
}

resource "aws_iam_role_policy_attachment" "external" {
  for_each = var.policy_arns

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
