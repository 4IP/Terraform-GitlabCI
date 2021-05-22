provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

resource "aws_lb_target_group" "ariefjr-tg" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "ariefjr-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_lb" "ariefjr-aws-alb" {
  name     = "ariefjr-alb"
  internal = false

  security_groups = [
    "${aws_security_group.ariefjr-alb-sg.id}",
  ]

  subnets = [
    "${var.private_subnet1}",
    "${var.private_subnet2}",
  ]

  tags = {
    Name = "ariefjr-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "ariefjr-alb-listener" {
  load_balancer_arn = "${aws_lb.ariefjr-aws-alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ariefjr-tg.arn}"
  }
}

resource "aws_security_group" "ariefjr-alb-sg" {
  name   = "ariefjr-alb-sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.ariefjr-alb-sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.ariefjr-alb-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.ariefjr-alb-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
