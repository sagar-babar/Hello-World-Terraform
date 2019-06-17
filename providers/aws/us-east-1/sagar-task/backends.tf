module "backends" {
  source          = "./backends/"
  private_subnets = "${local.private_subnets}"
  public_subnets  = "${local.public_subnets}"
  vpc_id          = "${local.vpc_id}"

  cluster_id       = "${module.ecs_cluster.cluster_id}"
  cluster_name     = "${module.ecs_cluster.cluster_name}"
  listener_arn     = "${module.ecs_cluster.listener_arn}"
