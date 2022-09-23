# Load Balancer Configuration

# Configure LB default security, configure blue/green target groups

# Set ingress on the loadbalancer to port 80 (HTTP) only
resource "aws_security_group" "lb" {
  name   = "example-alb-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the example/default loadbalancer (ALB)
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


# Local variables used in aws_lb_target_group, below
locals {
  target_groups = [
    "blue",
    "green",
  ]
}

# ALB Target Groups (Blue/Green)
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

# ALB Listener
resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world[0].arn
    type             = "forward"
  }
}