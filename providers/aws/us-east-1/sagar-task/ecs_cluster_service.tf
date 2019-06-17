variable "service_cluster_instance_type" { default = "t2.micro" }

variable "service_chef_run_list"  { type = "list"
                                        default = ["role[service-cluster]"]}

variable "ecs_service_ingress_alb_external_sg_ids" { default = [] }

variable "service_cluster_desired_instance" { default = "1" }

variable "service_cluster_min_instance" { default = "1" }

variable "service_cluster_max_instance" { default = "2" }

variable "vpc_private_subnets_ecs" { default = [""] }


module "ecs_cluster" {
  source    = "../../../../modules/aws/compute/ecs_cluster/"
  name      = "service-cluster"
  servers   = "${var.service_cluster_desired_instance}"
  min_servers = "${var.service_cluster_min_instance}"
  max_servers = "${var.service_cluster_max_instance}"
  subnet_id = "${var.vpc_private_subnets_ecs}"
  vpc_id    = "${local.vpc_id}"
  key_name  = "${local.key_name}"
  ami       = "${lookup(var.ecs_ami,var.aws_region)}"
  region    = "${var.aws_region}"

  custom_iam_policy_arns = "${aws_iam_policy.chef_policy.arn}"

  instance_type   = "${var.service_cluster_instance_type}"
  chef_server_url = "${var.chef_server_url}"
  chef_run_list   = "${var.service_chef_run_list}"
  chef_env        = "${var.env}"
  chef_bootstrap_bucket = "${var.chef_bootstrap_bucket}"
  ecs_container_metadata = true

  lb_internal     = true
  env             = true
  subdomain       = "${var.subdomain}"
  zone_id         = "${var.hosted_zone}"

  extra_tags      = [{
    key                 = "Monitor"
    value               = "Enable"
    propagate_at_launch = true
  }]

}

resource "aws_security_group_rule" "service_cluster_ingress" {
  count                    = "${length(local.ssh_allowed_sg)}"
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = "${element(local.ssh_allowed_sg, count.index)}"
  security_group_id        = "${module.ecs_cluster.ecs_cluster_sg_id}"
 }

 locals {
 ecs_service_ingress_alb_sg_ids = "${concat(var.ecs_service_ingress_alb_external_sg_ids,list(aws_security_group.vpn_sg.id,aws_security_group.jenkins_sg.id,module.ecs_cluster.ecs_cluster_sg_id))}"
 }

resource "aws_security_group_rule" "service_cluster_alb_ingress" {
  count                    = "${length(local.ecs_service_ingress_alb_sg_ids)}"
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  source_security_group_id = "${element(local.ecs_service_ingress_alb_sg_ids,count.index)}"
  security_group_id        = "${module.ecs_cluster.ecs_alb_sg_id}"
}
