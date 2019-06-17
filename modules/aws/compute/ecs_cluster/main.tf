variable "ebs_optimized"     { default = false }
variable "adjustment_type"   { default = "" }

variable "cluster_scaling_target_value" { default = 75}

variable "ecs_container_metadata" { default = false}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-${var.ami_version}-amazon-ecs-optimized"]
  }
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}


resource "aws_security_group" "ecs_sg" {
  name        = "${var.name}-ecs-sg"
  description = "controls access to the application ${var.name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_all_ingress" {
  count = "${var.enable_lb ? 1 : 0}"
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
  security_group_id = "${aws_security_group.ecs_sg.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "ALL"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ecs_sg.id}"
}

resource "aws_launch_template" "ecs" {
  name = "${coalesce(var.name_prefix, "${var.name}")}"
  vpc_security_group_ids = ["${var.security_groups}","${aws_security_group.ecs_sg.id}"]
  block_device_mappings {
    device_name = "${var.ebs_block_device}"
    ebs {
      volume_size = "${var.docker_storage_size}"
      volume_type = "gp2"
    }
  }
  block_device_mappings {
    device_name = "${var.root_block_device}"
    ebs {
      volume_size = "${var.root_storage_size}"
    }
  }

  disable_api_termination = false
  ebs_optimized = "${var.ebs_optimized}"
  iam_instance_profile {
    arn = "${aws_iam_instance_profile.ecs_profile.arn}"
  }
  image_id = "${var.ami == "" ? format("%s", data.aws_ami.ecs_ami.id) : var.ami}"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  tag_specifications {
    resource_type = "instance"
    tags {
      Name = "${var.name}-asg"
    }
  }
}

locals {
  tags = [{
     key                 = "Name"
     value               = "${var.name}-asg"
     propagate_at_launch = true
   }]
}
resource "aws_autoscaling_group" "ecs" {
  name_prefix          = "${var.name}-asg-"
  vpc_zone_identifier  = ["${var.subnet_id}"]
  launch_template = {
    id = "${aws_launch_template.ecs.id}"
    version = "$$Latest"
  }
  min_size             = "${var.min_servers}"
  max_size             = "${var.max_servers}"
  desired_capacity     = "${var.servers}"
  termination_policies = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour", "Default"]

  tags = ["${concat(var.extra_tags,local.tags)}"]

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["desired_capacity"]
  }
}


resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}"
}

resource "aws_autoscaling_policy" "ecs_cluster_target_tracking" {
  name                   = "${var.name}-target-tracking"
  adjustment_type        = "${var.adjustment_type}"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup  = 300
  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name = "ClusterName"
        value = "${var.name}"
      }
      metric_name = "MemoryReservation"
      namespace = "AWS/ECS"
      statistic = "Average"
    }
    target_value = "${var.cluster_scaling_target_value}"
  }
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"
}
