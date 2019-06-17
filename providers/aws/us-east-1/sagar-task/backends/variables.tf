variable "env"               { default = "dev"}
variable "vpc_id"            { }
variable "private_subnets"   { type = "list" }
variable "public_subnets"   { type = "list" }

variable "aws_region"       { default = "us-east-1" }
variable "aws_region_alias" { default = "use1" }

## service cluster vaiable ######################

variable "cluster_id"            { }
variable "cluster_name"          { }
variable "listener_arn"      {
  description = ""
}
