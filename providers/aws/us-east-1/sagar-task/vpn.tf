locals {
  vpn_name = "${var.env}-${var.vpn_name}"
}

resource "aws_iam_role" "vpn" {
  name               = "${local.vpn_name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_instance_profile" "vpn_profile" {
  name = "${local.vpn_name}"
  role = "${aws_iam_role.vpn.name}"
}

resource "aws_security_group" "vpn_sg" {
  name        = "${local.vpn_name}-sg"
  description = "controls access to the application ${local.vpn_name}"
  vpc_id = "${local.vpc_id}"
}

resource "aws_security_group_rule" "vpn_ingress" {
  type            = "ingress"
  from_port       = 1194
  to_port         = 1194
  protocol        = "udp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.vpn_sg.id}"
}

resource "aws_security_group_rule" "vpn_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vpn_sg.id}"
}

module "vpn" {
  source = "../../../../modules/aws/compute/genric_server"

  vpc_id          = "${local.vpc_id}"
  name            = "${var.env}-vpn-server"
  env             = "${var.env}"
  key_name        = "${aws_key_pair.key.key_name}"
  subnet_ids      = "${local.public_subnets}"
  security_groups = ["${aws_security_group.vpn_sg.id}"]
  ami             = "${var.amz1_ami[var.aws_region]}"
  iam_instance_profile = "${aws_iam_instance_profile.vpn_profile.name}"
  instance_type   = "t2.small"
  delete_on_termination   =  false
  aws_region      = "${var.aws_region}"
}

resource "aws_eip" "vpn" {
  vpc = true
  instance = "${module.vpn.instance_id[0]}"
  tags  {
     Name = "${var.env}-vpn-server"
  }
}
