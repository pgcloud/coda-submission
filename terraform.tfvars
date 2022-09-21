aws_region                       = "eu-west-1"
environment                      = "example"
vpc_azs                          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
vpc_cidr                         = "10.10.0.0/16"
ecr_force_delete                 = false # Mark as true to enable deletion of this IaC infrastructure.
ecs_example_task_family          = "hello-world-app"
ecs_example_task_initial_message = "Hello Coda - Message 1"
enable_nat_gateway               = true
enable_vpn_gateway               = false
vpc_name                         = "example_vpc"
vpc_database_subnets             = ["10.10.128.0/19", "10.10.160.0/19"] # Database Tier
vpc_private_subnets              = ["10.10.64.0/19", "10.10.96.0/19"]   # Private Tier (Backend)
vpc_public_subnets               = ["10.10.0.0/19", "10.10.32.0/19"]    # Public Tier
s3_force_delete                  = false

### CodeCommit Variables
source_repo_branch = "main"
source_repo_name   = "example"
