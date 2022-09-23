### 
# Task: Build a 3 tier VPC using terraform
#
# Author: Peter Griffin <peter.griffin@linux.com>
# Date: 19 September 2022
### 

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4" # Pin to the version used when creating this project
  name    = var.vpc_name
  cidr    = var.vpc_cidr

  azs              = var.vpc_azs
  database_subnets = var.vpc_database_subnets
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

### NACLs (Network Access Control Lists)

# Public Subnets
resource "aws_network_acl" "public" {
  depends_on = [module.vpc]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets.*

  # Ingress rules
  # All all local traffic
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = module.vpc.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  # Allow HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow HTTP
  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow the ephemeral ports from the internet
  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1025
    to_port    = 65534
  }

  ingress {
    protocol   = "udp"
    rule_no    = 104
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1025
    to_port    = 65534
  }

  # Egress rules
  # Allow all ports, protocols, and IPs outbound
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.vpc_name}-public-nacl"
  }

}