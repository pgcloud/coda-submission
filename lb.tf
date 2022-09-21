# Load Balancer Configuration

# Configure LB default security, configure blue/green target groups
#
#

resource "aws_security_group" "lb" {
  name   = "example-alb-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "default" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets.*
  security_groups    = [aws_security_group.lb.id]

  tags = {
    Name = "example-lb"
  }
}

locals {
  target_groups = [
    "green",
    "blue",
  ]
}

resource "aws_lb_target_group" "hello_world" {
  count       = length(local.target_groups)
  name        = "example-target-group-${element(local.target_groups, count.index)}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

}

resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world[0].arn
    type             = "forward"
  }
}