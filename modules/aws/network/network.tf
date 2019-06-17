variable "env"              { }

variable "azs"                { type = "list" }
variable "public_subnets"     { type = "list" }
variable "private_subnets"    { type = "list" }
variable "cidr"               { }
variable "enable_nat_gateway" { default = true }

variable "create_database_subnet_group"  { default = true }
variable "create_cache_subnet_group"  { default = true }

locals {
  name = "${var.env}-vpc"
  default_tags = {  Terraform   = "true"
                    Environment = "${var.env}" }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.34.0"
  name = "${local.name}"
  cidr = "${var.cidr}"
  
  azs             = "${var.azs}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
  enable_dns_hostnames   = true
  enable_nat_gateway     = "${var.enable_nat_gateway}"
  enable_vpn_gateway     = false
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = "${var.env}"
    Name        = "${local.name}"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  count = "${var.create_database_subnet_group}"

  name        = "${lower(var.env)}-vpc-rds-subnet-group"
  description = "Database subnet group for ${local.name}"
  subnet_ids  = ["${module.vpc.private_subnets}"]
  #tags = "${local.default_tags}"
  tags = "${merge(local.default_tags, map("Name", format("%s", local.name)))}"
}

resource "aws_elasticache_subnet_group" "elastic_cache_subnet_group" {
  count = "${var.create_cache_subnet_group}"
  name       = "${lower(local.name)}-cache-subnet-group"
  subnet_ids = ["${module.vpc.private_subnets}"]
}

output "private_subnets" { value = "${module.vpc.private_subnets}"} 
output "public_subnets" { value = "${module.vpc.public_subnets}"} 
output "db_subnets" { value = "${aws_db_subnet_group.database_subnet_group.0.id}"}
output "cache_subnet" { value = "${aws_elasticache_subnet_group.elastic_cache_subnet_group.0.id}"}
output "private_route_table_ids" { value = "${module.vpc.private_route_table_ids}" }
output "public_route_table_ids" { value = "${module.vpc.public_route_table_ids}" }
output "vpc_id" {value = "${module.vpc.vpc_id}" }
