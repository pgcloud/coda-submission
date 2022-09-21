###################################################
# Codapayments Assignment
# Task: 
#   On AWS, Using IaC (Terraform or CloudFormation), configure 3-tier VPC and an ECS Cluster. 
#   Using CI/CD demonstrate rolling update / blue-green deployment with a sample containerised application that can be configured via environment variables.
#   For CI/CD, you can use AWS native developer services (e.g. CodeBuild, CodePipeline, CodeCommit) or 3rd party tools (e.g. Jenkins, GitLab, etc.).
#
# Terraform components:
#   * main.tf (This file - in this case used as a table of contents/index, smaller projects may forgo this and use the main.tf directly)
#   * vpc.tf - Contains the logic to build the 3 tier VPC (using the terraform-aws-vpc community module), and the associated route tables, security groups and subnets
#   * ecsecr.tf - Create the ecs cluster, and ecr registry
#   * codebuild.tf - set up the codebuild IAM role, policy and codebuild project
#   * codecommit.tf - set up the codecommit repository, iam roles, and cloudwatch event rules
#   * codepipeline.tf - set up the codepipeline iam roles, policies and the codepipline itself
###################################################

########################
# Reference Materials
# 3 Tier Architecture: https://towardsaws.com/together-we-build-an-aws-3-tier-architecture-62db9bba4f3a
# ECS Blue/Green: https://www.theairtips.com/post/setting-up-blue-green-deployment-for-your-application-in-aws-ecs-using-code-pipeline
#
#########################
