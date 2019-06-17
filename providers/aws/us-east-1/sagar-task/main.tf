variable "aws_profile"      { default = ""}
variable "aws_region"       { default = "us-east-1" }
variable "env"              { }
variable "aws_region_alias" { default = "use1" }
variable "vpc_azs"                { type = "list" }
variable "vpc_public_subnets"     { type = "list" }
variable "vpc_private_subnets"    { type = "list" }
variable "vpc_cidr"               { }
variable "subdomain"              { default = ""}

variable "create_database_subnet_group"  { default = true }

variable "base_ami"              { type = "map" }
variable "amz1_ami"              { type = "map" }
variable "ecs_ami"              { type = "map" }

provider "aws" {
  region   = "${var.aws_region}"
  profile  = "${var.aws_profile}"
  version  = "~> 2.6.0"
}

locals {
  name = "${var.env}-vpc"
  default_tags = {  Terraform   = "true"
                    Environment = "${var.env}" }
}

locals {
  ssh_allowed_sg = ["${aws_security_group.vpn_sg.id}"]
}

module "vpc" {
  source = "../../../../modules/aws/network/"

  cidr = "${var.vpc_cidr}"
  env             = "${var.env}"
  azs             = "${var.vpc_azs}"
  private_subnets = "${var.vpc_private_subnets}"
  public_subnets  = "${var.vpc_public_subnets}"
}

resource "aws_key_pair" "key" {
  key_name   = "${var.env}-key"
  public_key = "${file("data/sagar-key.pub")}"
}

locals {
  vpc_id            = "${module.vpc.vpc_id}"
  public_subnets    = "${module.vpc.public_subnets}"
  private_subnets   = "${module.vpc.private_subnets}"
  key_name          = "${aws_key_pair.key.key_name}"
  cache_subnet      = "${module.vpc.cache_subnet}"
  private_route_table_id = "${module.vpc.private_route_table_ids[0]}"
  public_route_table_id = "${module.vpc.public_route_table_ids[0]}"
}
output "vpc_id" { value = "${local.vpc_id}"}
