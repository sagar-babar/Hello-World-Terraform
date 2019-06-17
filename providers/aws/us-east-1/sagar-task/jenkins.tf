variable "jenkins_name" { default = "jenkins" }
locals {
  jenkins_name = "${var.env}-${var.jenkins_name}"
}

resource "aws_iam_role" "jenkins" {
  name               = "${local.jenkins_name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${local.jenkins_name}"
  role = "${aws_iam_role.jenkins.name}"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${local.jenkins_name}-sg"
  description = "controls access to the application ${local.jenkins_name}"
  vpc_id = "${local.vpc_id}"
}

locals {
jenkins_ingress = "${list(module.ecs_cluster.ecs_cluster_sg_id,local.ssh_allowed_sg[0])}"
}

resource "aws_security_group_rule" "jenkins_ingress" {
  type            = "ingress"
  count           = "${length(local.jenkins_ingress)}"
  from_port       = 8080
  to_port         = 8080
  protocol        = "tcp"
  source_security_group_id    = "${element(local.jenkins_ingress,count.index)}"
  security_group_id = "${aws_security_group.jenkins_sg.id}"
}

resource "aws_security_group_rule" "jenkins_ssh_ingress" {
  count                    = "${length(local.ssh_allowed_sg)}"
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = "${element(local.ssh_allowed_sg, count.index)}"
  security_group_id = "${aws_security_group.jenkins_sg.id}"
}


resource "aws_security_group_rule" "jenkins_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.jenkins_sg.id}"
}

module "jenkins" {
  source = "../../../../modules/aws/compute/genric_server"

  vpc_id          = "${local.vpc_id}"
  name            = "${var.env}-jenkins-server"
  env             = "${var.env}"
  key_name        = "${aws_key_pair.key.key_name}"
  subnet_ids      = "${local.private_subnets}"
  security_groups = ["${aws_security_group.jenkins_sg.id}"]
  ami             = "${var.amz1_ami[var.aws_region]}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_profile.name}"
  instance_type   = "t2.medium"
  delete_on_termination   =  false
  aws_region      = "${var.aws_region}"
}
