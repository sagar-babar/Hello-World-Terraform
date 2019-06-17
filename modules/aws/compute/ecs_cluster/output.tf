output "cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.cluster.name}"
}

output "autoscaling_group" {
  value = {
    id   = "${aws_autoscaling_group.ecs.id}"
    name = "${aws_autoscaling_group.ecs.name}"
    arn  = "${aws_autoscaling_group.ecs.arn}"
  }
}

output "ecs_alb_sg_id" { value = "${element(concat(aws_security_group.alb_sg.*.id,list("")),0)}" }
output "iam_role_name" { value = "${aws_iam_role.ecs_role.name}" }
output "alb_arn" { value = "${element(concat(aws_alb.main.*.arn,list("")),0)}" }
output "listener_arn" { value = "${element(coalescelist(aws_alb_listener.main.*.arn,aws_alb_listener.main_https.*.arn,list("")),0)}" }
output "ecs_cluster_sg_id" { value = "${aws_security_group.ecs_sg.id}"}
