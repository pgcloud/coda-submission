###################################################
# Codapayments Assignment
#
# Author: Peter Griffin <peter.griffin@linux.com>
# Submission Date: 23/09/2022
#
# Task: 
#   On AWS, Using IaC (Terraform or CloudFormation), configure 3-tier VPC and an ECS Cluster. 
#   Using CI/CD demonstrate rolling update / blue-green deployment with a sample containerised application that can be configured via environment variables.
#   For CI/CD, you can use AWS native developer services (e.g. CodeBuild, CodePipeline, CodeCommit) or 3rd party tools (e.g. Jenkins, GitLab, etc.).
#
# Terraform components:
#   * main.tf (This file - in this case used as a table of contents/index, smaller projects may forgo this and use the main.tf directly)
#   * codebuild.tf - contains the code to build the CodeBuild project, and insert the required Environment variables for use in the build process
#     (to build the appspec.yaml file used by CodeDeploy/ECS)
#
#   * codecommit.tf - contains the code to build the CodeCommit repository, along with tha IAM role and policies to allow Cloudwatch to
#     trigger CodePipeline upon a change to the git branch as specified in the `terraform.tfvars` file
#
#   * codedeploy.tf - contains the code to build the CodeDeploy deployment
#     This includes logic to build the blue/green deployment as well as the IAM role and policies to provision access to S3, ECS and the LoadBalancer
#
#   * codepipeline.tf - contains the code to build the CodePipeline itself, as well as provision the S3 bucket used to store the build artifacts and the 
#     IAM role and policy to assume permissions to be able to access ECS, CodeCommit, CodeDeploy and CodeBuild
# 
#   * ecsecr.tf - contains the code to build the ECR registry, as well as the ECS cluster, the ECS tasks security group, and ECS task definition,
#     and the IAM role and permissions for ECS to be able to execute the task
#      
#   * lb.tf - contains the code to deploy the Application Load Balancer (ALB)
#     Includes the load balancer itself, the security group to limit inbound traffic to port 80, as well as the two (blue, green) target groups
#     that are used to perform blue/green deployments on ECS
# 
#   * providers.tf - Contains the configuration for the required terraform providers. In this case, just the `aws` provider. With the version pinned to the latest as of time of writing
#   * README.md - Main documentation file for this project, in MarkDown (md) format
#   * terraform.tfvars - Contains the provided (samply) terraform variables. Can be used as-is, or reviewed and modified as needed
#   * variables.tf - Contains the list of variables used by this Terraform project
#   * vpc.tf - Contains the code to deploy a 3 Tier VPC (utilising the terraform-aws-vpc community module, with a pinned version), and the associated NACL ruleset
#
#
# Sample Application Components (inside /build sub-folder):
#   * /app folder - Contains the sample nodejs application
#   * appspec_template.yaml - Template file to be used in concert with the `envsub` tool to generate a appspect.yaml file during the build process
#   * buildspec.yml - BuildSpec file used by the CodeBuild process to build the container and required artifacts for CodeDeploy to push update to ECS
#
#   * push-to-ecr.sh - Bash script to build and deploy sample application to ECR.
#
#   This is one of two methods to deploy the code to ECS.
#   The second method is to copy the entire /build folder to a new folder, and use CodeCommit to push to the repository as specified in the
#   `source_repo_name` variable in the `terraform.tfvars` file
#
#   If the first method is used, the update to the ECR (Container Registry) is detected via the ECS controller and the new image is deployed via blue/green.
#   If the second method is used, the CodePipeline detects the change to the CodeCommit registry and kicks off CodeBuild to build and package the code to ECR,
#   then CodeDeploy to push the code via Blue/Green to ECS
#
#   Note, that (per the README.md) one of these methods has to be chosen after running `terraform apply` for the first time, otherwise the container will
#   not be created and ECS will be unable to start successfully
#
#
# Terraform Build Instructions:
#
#  1. Ensure that the AWS access is provisioned, either via a AWS configuration file, or by exporting the
#  `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables
#  2. Review the terraform.tfvars file, and make changes as necessary
#  3. Run `terraform plan`
#  4. If satisfied with the Output from step 3, run `terraform apply` and type `yes` when prompted
#
#  Note: As per the README.md, the ECS cluster requires the NodeJS application (in the /build folder of this repository) to be
#  uploaded before the service will start. Otherwise it will advise the container cannot be found
#
#  There are two ways to deploy this:
#  1. Copy the entire /build folder to a new folder, configure for CodeCommit and push the code to CodeCommit
#  2. (For Testing/PoC purposes) use the provided push-to-ecr.sh script in the build folder to build the container using docker and push to ECR
###################################################

########################
# Reference Materials
# 3 Tier Architecture: https://towardsaws.com/together-we-build-an-aws-3-tier-architecture-62db9bba4f3a
# ECS Blue/Green: https://www.theairtips.com/post/setting-up-blue-green-deployment-for-your-application-in-aws-ecs-using-code-pipeline
#########################
