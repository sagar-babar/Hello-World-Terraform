
locals {
  default_tags      = {  Terraform   = "true"
                         Environment = "${var.env}" }
  vpc_id            = "${var.vpc_id}"
  public_subnets    = "${var.public_subnets}"
  private_subnets   = "${var.private_subnets}"
}
