# Create ECR Repository
resource "aws_ecr_repository" "example" {
  name                 = "example"
  image_tag_mutability = "MUTABLE"
  force_delete         = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true #Automatically scan images for vulnerabilities
  }
}

# Create example ecs cluster
resource "aws_ecs_cluster" "example" {
  depends_on = [module.vpc]
  name       = "example-cluster"
}

# create ecs security group
resource "aws_security_group" "hello_world_task" {
  depends_on = [ aws_security_group.lb ]
  name   = "example-task-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    security_groups = [ aws_security_group.lb.id ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create the AssumeRole link to allow the ECS task definition to execute
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# create ecs task definition
resource "aws_ecs_task_definition" "hello_world" {
  depends_on               = [module.vpc, aws_ecr_repository.example]
  family                   = var.ecs_example_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.example.repository_url}",
    "cpu": 256,
    "environment": [
        {"name": "MESSAGE", "value": "${var.ecs_example_task_initial_message}" }
    ],
    "memory": 256,
    "name": "hello-world-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

# create ecs service
resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.hello_world_task.id]
    subnets         = module.vpc.private_subnets.*
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world[0].arn
    container_name   = "hello-world-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.hello_world]
  lifecycle {
    ignore_changes = [task_definition, load_balancer] # Allow CI/CD to update task_definition without terraform attempting to correct this "drift" on subsequent runs
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}