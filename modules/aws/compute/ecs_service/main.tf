
locals {
  data =  {
      container_name   = "${var.name}",
      container_port   = "${var.container_port}",
      mem              = "${var.container_mem}",
      cpu              = "${var.container_cpu}",
      image            = "${var.container_image}",
      env              = "${var.container_env}",
      volume_map       = "${var.container_volume_map}",
      command          = "${var.container_command}"
      name             = "${var.name}"
      ulimit           = "${var.ulimit}"
      read_only_volume = "${var.read_only_volume}"
  }
}


data "gotemplate" "container_defination" {
  template = "${file("${path.module}/defination.tmpl")}"
  data = "${jsonencode(local.data)}"
}

resource "aws_ecs_task_definition" "service" {
  family                = "${var.name}"
  container_definitions = "${data.gotemplate.container_defination.rendered}"
  task_role_arn         = "${var.task_role_arn}"

  volume = "${var.host_volume_map}"
}

data "aws_ecs_task_definition" "service" {
  task_definition = "${aws_ecs_task_definition.service.family}"
  depends_on = ["aws_ecs_task_definition.service"]
}


resource "aws_alb_target_group" "service" {
  count = "${var.enable_lb ? 1 : 0}"
  name  = "${format("%.32s",var.name)}"  #alb target group name can be of max 32 chars
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check = "${var.lb_health_check}"

   tags {
     Name = "${var.name}"
     enviroment = "${var.env}"
     terraform = "true"
   }

   lifecycle {
    create_before_destroy = true
    ignore_changes = "lambda_multi_value_headers_enabled"
   }

  deregistration_delay = "${var.deregistration_delay}"

}

resource "aws_lb_listener_rule" "host_based_routing" {
  count = "${var.enable_lb ? 1 : 0}"
  listener_arn = "${var.listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.service.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["${var.path}"]
  }
}

resource "aws_ecs_service" "service" {
  lifecycle = {
    ignore_changes   = ["desired_count"]
  }
  depends_on = ["aws_lb_listener_rule.host_based_routing"]
  count = "${var.enable_lb ? 1 : 0}"
  name            = "${var.name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.service.family}:${max("${aws_ecs_task_definition.service.revision}", "${data.aws_ecs_task_definition.service.revision}")}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.ecs_service_role_arn}"

  scheduling_strategy = "${var.scheduling_strategy}"

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.service.arn}"
    container_name   = "${var.name}"
    container_port   = "${var.container_port}"
  }
}

resource "aws_ecs_service" "service_without_alb" {
  lifecycle = {
    ignore_changes   = ["desired_count"]
  }
  count           = "${var.enable_lb ? 0 : (var.scheduling_strategy == "DAEMON" ? 0 : 1)}"
  name            = "${var.name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.service.family}:${max("${aws_ecs_task_definition.service.revision}", "${data.aws_ecs_task_definition.service.revision}")}"
  desired_count   = "${var.desired_count}"

  scheduling_strategy = "${var.scheduling_strategy}"

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

}

resource "aws_ecs_service" "service_daemon" {
  lifecycle = {
    ignore_changes   = ["desired_count"]
  }
  count           = "${var.scheduling_strategy == "DAEMON"? 1 : 0}"
  name            = "${var.name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.service.family}:${max("${aws_ecs_task_definition.service.revision}", "${data.aws_ecs_task_definition.service.revision}")}"
  desired_count   = "${var.desired_count}"

  scheduling_strategy = "${var.scheduling_strategy}"

}

resource "aws_appautoscaling_target" "ecs_target" {
  depends_on = ["aws_ecs_service.service","aws_ecs_service.service_without_alb"]
  count              = "${var.enable_autoscaling ? 1 : 0}"
  max_capacity       = "${var.max_capacity}"
  min_capacity       = "${var.min_capacity}"
  resource_id        = "service/${var.ecs_cluster_name}/${var.name}"
  role_arn           = "${var.ecs_autoscale_role}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  count                   = "${var.enable_autoscaling ? 1 * (var.scaling_policy_type == "TargetTrackingScaling" ? 1 : 0) : 0}"
  name                    = "${var.name}-target-tracking"
  policy_type             = "TargetTrackingScaling"
  resource_id             = "service/${var.ecs_cluster_name}/${var.name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  service_namespace       = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "${var.predefined_metric_type}"
    }
    target_value = "${var.autoscale_target_value}"
    scale_in_cooldown = "${var.scale_in_cooldown}"
    scale_out_cooldown = "${var.scale_out_cooldown}"
  }

   depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_appautoscaling_policy" "ecs_policy_with_step_scaling" {
  count                   = "${var.enable_autoscaling ? 1 * (var.scaling_policy_type == "TargetTrackingScaling" ? 0 : 1) : 0}"
  name                    = "${var.name}-step-scaling"
  policy_type             = "StepScaling"
  resource_id             = "service/${var.ecs_cluster_name}/${var.name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  service_namespace       = "ecs"


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment = "${var.step_adjustment}"
  }
   depends_on = ["aws_appautoscaling_target.ecs_target"]
}
output "compute_data" {
  value = "${local.data}"
}
