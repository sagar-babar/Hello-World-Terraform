resource "random_string" "db_password" {
  length = 22
  special = false
}

module "rds_hello_world" {
  source                        = "../../../../modules/aws/database/rds"

  env                           = "${var.env}"
  identifier                    = "hello-world-postgres-1"
  engine                        = "postgres"
  instance_class                = "db.t2.micro"
  port                          = 5432
  name                          = "HelloWorld"
  username                      = "dbuser"
  password                      = "${random_string.db_password.result}"
  allocated_storage             = 10
  backup_retention_period       = 3
  publicly_accessible           = false
  set_password                  = true
  # DB parameter group
  family                        = "postgres9.6"
  engine_version                = "9.6.6"
  # DB option group
  major_engine_version          = "9.6.6"
  db_subnet_group_name          = "${module.vpc.db_subnets}"
  source_security_group_id      = ["${module.ecs_cluster.ecs_cluster_sg_id}"]
  vpc_id                        = "${local.vpc_id}"
}
