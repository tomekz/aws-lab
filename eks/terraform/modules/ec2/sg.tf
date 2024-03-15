resource "aws_security_group" "this" {

  name = "${var.name}-sg"

  description = "${var.name} SG"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-sg" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "TCP"
  description       = "(terraform) Inbound TCP/443"
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "(terraform) Outbound All/All"
}
