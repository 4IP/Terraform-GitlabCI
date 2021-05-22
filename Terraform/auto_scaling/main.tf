provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

resource "aws_launch_configuration" "ariefjr-launch-config" {
  image_id        = "ami-0d058fe428540cd89"
  instance_type   = "t2.medium"
  security_groups = ["${aws_security_group.ariefjr-asg-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              apt install nginx -y
              echo "Hello, Stockbit Test" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-ariefjr" {
  name                 = "asg-ariefjr"
  launch_configuration = "${aws_launch_configuration.ariefjr-launch-config.name}"
  vpc_zone_identifier  = ["${var.private_subnet1}", "${var.private_subnet2}"]
  target_group_arns    = ["${var.target_group_arn}"]
  health_check_type    = "ELB"

  desired_capacity = 2
  min_size = 2
  max_size = 5

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  tag {
    key                 = "Name"
    value               = "ariefjr-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "ariefjr-asg_policy" {
  name = "ariefjr-asg_policy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg-ariefjr.name}"
}

resource "aws_cloudwatch_metric_alarm" "ariefjr-asg_cpu_alarm" {
  alarm_name = "ariefjr-asg_cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "45"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg-ariefjr.name}"
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ aws_autoscaling_policy.ariefjr-asg_policy.arn ]
}


resource "aws_security_group" "ariefjr-asg-sg" {
  name   = "ariefjr-asg-sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.ariefjr-asg-sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.ariefjr-asg-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.ariefjr-asg-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
