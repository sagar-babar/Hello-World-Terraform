locals {
lb_listen_port = "80"
}


resource "aws_alb" "main" {
  count = "${var.enable_lb ? 1 : 0}"

  internal        = "${var.lb_internal}"
  subnets         = ["${var.subnet_id}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
  name            = "${var.name}-alb"
  idle_timeout    = "180"
  tags =  { name = "${var.name}"
            terraform = true
            env       = "${var.env}"
           }

}

resource "aws_alb_listener" "main" {
  count = "${var.enable_lb ? (var.https ? 0 : 1) : 0 }"

  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "main" {
  count = "${var.enable_lb ? 1 : 0}"

  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check = "${var.lb_health_check}"
  name        = "${replace(format("%.32s","${var.name}-default-tg"),"/-$/","")}"
  lifecycle {
     ignore_changes = "lambda_multi_value_headers_enabled"
   }
}

resource "aws_security_group" "alb_sg" {
  count = "${var.enable_lb ? 1 : 0}"
  name        = "${var.name}-alb-sg"
  description = "controls access to the application LB"
  vpc_id = "${var.vpc_id}"
}


resource "aws_security_group_rule" "alb_allow_self_http" {
  count = "${var.enable_lb ? 1 : 0}"
  type            = "ingress"
  from_port       = "${local.lb_listen_port}"
  to_port         = "${local.lb_listen_port}"
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb_sg.id}"
}

resource "aws_security_group_rule" "alb_allow_all_egress" {
  count = "${var.enable_lb ? 1 : 0}"
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb_sg.id}"
}
