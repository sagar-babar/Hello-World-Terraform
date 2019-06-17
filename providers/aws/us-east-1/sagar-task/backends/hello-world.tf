resource "aws_iam_role" "hello-world_task_role" {
  name               = "${var.aws_region_alias}-${var.env}-${local.hello-world["name"]}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume_role_policy.json}"
}

locals {
 hello-world = {
   name  = "hello-world",
   port  = 80,
   image = "550434343742.dkr.ecr.us-east-1.amazonaws.com/sagar/hello-world:hello-world-1-1"
   path  = "/hello-world*"
 }
}

module "ecs_service_hello-world" {
  source    = "../../../../../modules/aws/compute/ecs_service/"
  name      = "${var.env}-${local.hello-world["name"]}"
  subnet_ids = "${local.private_subnets}"
  vpc_id     = "${local.vpc_id}"
  path       = "${local.hello-world["path"]}"

  ecs_cluster_id       = "${var.cluster_id}"
  ecs_cluster_name     = "${var.cluster_name}"
  env                  = "${var.env}"
  container_image      = "${local.hello-world["image"]}"
  container_port       = "${local.hello-world["port"]}"
  container_env = {
     AWS_DEFAULT_REGION = "${var.aws_region}"
     LANDSCAPE  = "${var.env}"
  }

  lb_health_check = [ {
    path = "/hello-world/",
    healthy_threshold = 2,
    unhealthy_threshold = 2
  } ]

  ulimit =  {
    hard_limit = "4096"
    soft_limit = "4096"
  }

  container_mem = "512"

  container_volume_map = {}

  listener_arn = "${var.listener_arn}"

  task_role_arn = "${aws_iam_role.hello-world_task_role.arn}"

  host_volume_map = []

  desired_count   = 1
}
