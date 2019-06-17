variable "additional_user_data_script" {
  default = ""
}

variable "ami" {
  default = ""
}

variable "ami_version" {
  default = "*"
}

variable "associate_public_ip_address" {
  default = false
}

variable "docker_storage_size" {
  default     = "100"
  description = "EBS Volume size in Gib that the ECS Instance uses for Docker images and metadata "
}

variable "root_block_device" {
  default     = "/dev/xvda"
  description = "EBS  root block devices to attach to the instance. (default: /dev/xvdca)"
}

variable "ebs_block_device" {
  default     = "/dev/xvdcz"
  description = "EBS block devices to attach to the instance. (default: /dev/xvdcz)"
}

variable "root_storage_size" {
  default     = "32"
  description = "EBS Volume size in Gib that the ECS Instance uses for Docker images and metadata "
}

variable "extra_tags" {
  default = [{}]
}

variable "heartbeat_timeout" {
  description = "Heartbeat Timeout setting for how long it takes for the graceful shutodwn hook takes to timeout. This is useful when deploying clustered applications like consul that benifit from having a deploy between autoscaling create/destroy actions. Defaults to 180"
  default     = "180"
}

variable "iam_path" {
  default     = "/"
  description = "IAM path, this is useful when creating resources with the same name across multiple regions. Defaults to /"
}

variable "custom_iam_policy" {
  default     = ""
  description = "Custom IAM policy (JSON). If set will overwrite the default one"
}

variable "custom_iam_policy_arns" {
  default     = ""
  description = "Custom IAM policy arn. comma sepereted arn values"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "min_servers" {
  description = "Minimum number of ECS servers to run."
  default     = 1
}

variable "max_servers" {
  description = "Maximum number of ECS servers to run."
  default     = 10
}

variable "name" {
  description = "AWS ECS Cluster Name"
}

variable "env" {
  description = "AWS ECS Cluster env"
  default = ""
}


variable "name_prefix" {
  default = ""
}

variable "region" {
  default     = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "registrator_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 20"
  default     = "32"
}

variable "security_groups" {
  type        = "list"
  description = "A list of Security group IDs to apply to the launch configuration"
  default     = []
}

variable "servers" {
  default     = "1"
  description = "The number of servers to launch."
}

variable "subnet_id" {
  type        = "list"
  description = "The AWS Subnet ID in which you want to delpoy your instances"
}

variable "tagName" {
  default     = "ECS Node"
  description = "Name tag for the servers"
}

variable "user_data" {
  default = ""
}

variable "vpc_id" {
  description = "The AWS VPC ID which you want to deploy your instances"
}

variable "enable_lb" {
  description = "create alb with cluster"
  default = true
}

variable "lb_internal" {
  description = "whether to create inernal alb or external"
  default = true
}

variable "lb_health_check" {
  description = "health check for default target"
  default = [{}]
  type = "list"
}

variable "subdomain" {
  default = ""
}

variable "zone_id" {
 default = ""
}

variable "certificate_arn" {
 default = ""
}

variable "https" {
 default = false
}
