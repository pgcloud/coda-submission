variable "aws_region" {
  description = "The (default) region to instantiate the AWS provider into"
  type        = string
}

variable "ecr_force_delete" {
  description = "Whether to allow terraform (via the AWS API) to remove all the images inside a repository when that repository is marked to be deleted. If this is set to false, a delete action on this IaC will fail"
  type        = bool
}

variable "ecs_example_task_initial_message" {
  description = "The initial message (presented as an environment variable) to display in the hello-world container's webpage"
  type        = string
}

variable "ecs_example_task_family" {
  description = "Family of the ECS task definition"
  type        = string
}

variable "environment" {
  description = "The Environment that this project is being deployed into, for example: Test, Dev, QA, Prod"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to allow egress traffic to the internet, via a NAT gateway"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Whether to provision a VPN gateway. Outside the scope of this project, so we will disable"
  type        = bool
  default     = false
}

variable "source_repo_branch" {
  description = "The name of the branch (let's stick with main for this example, however I'd expect a gitflow style pattern in a real scenario)"
  type        = string
}

variable "source_repo_name" {
  description = "The name of the repository to push code to"
  type        = string
}

variable "vpc_azs" {
  description = "The desired AWS az's to be utilized. Specified as per AWS AZ notation. ie: ap-southeast-1a, ap-southeast-1b, et.al"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The desired Cidr range for the VPC, as specified in the XX/X notation."
  type        = string
}

variable "vpc_database_subnets" {
  description = "Create private subnets dedicated to data storage/tier"
  type        = list(string)
}

variable "vpc_name" {
  description = "The name of the VPC, as displayed in AWS' console and API"
  type        = string
  # default = "example_vpc"
  # Note: The default is not being enabled as we want this VPC creation
  #       process to fail if the name is not allocated
}

variable "vpc_private_subnets" {
  description = "A list of strings specifying the private subnet cidr Ranges. For example - ['10.250.128.0/19', '10.250.160.0/19', '10.250.192.0/19']"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "A list of strings specifying the public subnet cidr Ranges. For example - ['10.250.0.0/19', '10.250.32.0/19', '10.250.64.0/19']"
  type        = list(string)
}

variable "s3_force_delete" {
  description = "Whether to delete a non-empty S3 bucket. Warning: All items inside the bucket are non-recoverable. Use this *ONLY* when running a force delete you are 100% sure about"
  type        = bool
}