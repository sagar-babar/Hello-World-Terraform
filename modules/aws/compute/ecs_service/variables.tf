variable "container_env" {
  default = {
     "name"=  "sagar",
     "region" = "us-east-1"
  }
}

variable "container_volume_map"  { type = "map"
                                   default = {} }

variable "container_image" { }
variable "container_cpu" { default = 2 }
variable "container_mem" { default = 256 }
variable "container_command" { default = [] }

variable "vpc_id" {
  description = "ID of the VPC."
  type        = "string"
}

variable "listener_arn" {
  default = ""
}

variable "env" {
  description = "Logical name of the environment, will be used as prefix and in tags."
  type        = "string"
}

variable "subnet_ids" {
  description = "List of subnets to which the load balancer needs to be attached. Mandatory when enable_lb = true."
  type        = "list"
  default     = []
}

variable "container_port" {
  default = 9000
}

variable "host_volume_map" {
  type = "list"
  default = []
}

variable "task_role_arn" {
  description = "The AWS IAM role that will be provided to the task to perform AWS actions."
  type        = "string"
  default     = ""
}

variable "ecs_cluster_id" {
  description = "The id of the ECS cluster"
  type        = "string"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = "string"
  default     = ""
}


variable "name" {
  description = "Logical name of the service."
  type        = "string"
}

variable "desired_count" {
  description = "The number of services that needs to be created."
  default     = "1"
}

variable "lb_health_check" {
  description = "A health check block for the load balancer, see https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html more for details."
  type        = "list"
  default     = [
                  {
                    path = "/",
                    healthy_threshold = 2,
                    unhealthy_threshold = 2
                  }
                ]
}

variable "enable_lb" {
  description = "Enable or disable the load balancer."
  default     = true
}

variable "ecs_service_role" {
  default = ""
}

variable "host_path" {
  default = ""
  description = "host path for container volume map"
}

variable "ecs_service_role_arn" {
  default = "arn:aws:iam::366611831214:role/ecsServiceRole"
}

variable "source" {
  default = ""
}

variable "path" {
  default = ""
  description = "target group path"
}

variable "ulimit" {
  type = "map"
  default = {
    hard_limit = 4096
    soft_limit = 4096
 }
}

variable "enable_autoscaling" {
  default = true
}

variable "predefined_metric_type" {
  default = "ECSServiceAverageMemoryUtilization"
}

variable "step_adjustment" {
  type = "list"
  default =  [{
    metric_interval_upper_bound = 0
    scaling_adjustment = -1
  },
  {
    metric_interval_lower_bound = 0
    scaling_adjustment = 1
  }]

}

variable "autoscale_target_value" {
  default = 65
}

variable "scale_in_cooldown" {
  default = 300
}

variable "scale_out_cooldown" {
  default = 300
}

variable "max_capacity" {
  default = "5"
}

variable "min_capacity" {
  default = "1"
}

variable "scaling_policy_type" {
 default = "TargetTrackingScaling"
}

variable "ecs_autoscale_role" {
 default = "arn:aws:iam::550434343742:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
}

variable "deregistration_delay" {
 default = "120"
}

## read_only_volume is a string not boolean
variable "read_only_volume" {
 default = "true"
}

variable "scheduling_strategy"  {
  default = "REPLICA"
}

variable "aws_region_alias" { default = "use1" }
