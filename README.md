## CodaPayments Assignment Submission

<br />

### Assigned Task

* On AWS, Using IaC (Terraform or CloudFormation), configure 3-tier VPC and an ECS Cluster. 
* Using CI/CD demonstrate rolling update / blue-green deployment with a sample containerised application that can be configured via environment variables.
    * For CI/CD, you can use AWS native developer services (e.g. CodeBuild, CodePipeline, CodeCommit) or 3rd party tools (e.g. Jenkins, GitLab, etc.).


### Task #1

Build Instructions

1. Ensure that the appropriate permissions are set up for terraform to connect to the AWS API. Whilst in a production environment the AWS credentials would be securely stored and the terraform actions ran by a 3rd party tool such as a `Github action` or Hashicorp's own `Terraform Cloud`, in this assignment, as this is not expected to get promoted to a production environment, we leverage environment variables. Thus please ensure the follow variables are set before running terraform
    
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`

2. Review the `terraform.tfvars` file, and if the values are satisfactory (for example, the Region and AZ settings for the VPC) then continue

3. Run `terraform plan` and read the output (This duplicates in the `terraform apply` step, this is to ensure the output is reviewed)

4. If satisfied, run `terraform apply` and type `yes` when requested, if the plan (see step 3) is satisfactory.

5. Terraform will connect to AWS and deploy the 3 tier VPC, the infrastructure for the ECS cluster and the task definition AND the codebuild/codepipeline/codecommit CI/CD infrastructure. 

Wait for this task to be completed. Please note at this stage the codepipeline will fail, as there is no code in the git repository. However, the initial deployment of the ECS service will still succeed. See Task #2 on how to push code to the git repo, and update/modify the running service and it's tasks

6. Traverse to the `build` folder in this repo and review the `push-to-ecr.sh` file. Change the `MY_AWS_REGION` to match the region specified in the `terraform.tfvars` file.

7. Run the `push-to-ecr.sh` file

8. Connect to the URI presented in the terraform output from step 5 to view the website. Alternatively, review the ECS cluster in the AWS console.


### Task #2





### Addendum

Outstanding Issues:

The S3 bucket created by terraform is subsequently modified by Codepipeline, and even with `force delete` = `true` enabled, the bucket is unable to be deleted by Terraform during a `destroy` run. This is an issue that with additional time could be solved, however, the current recommendation is to empty then delete the S3 bucket, either via the CLI or GUI, prior to running `terraform destroy`

Additionally there is an issue with deleting the created ECR registry, after an image has been deployed into it. Same advice as for the S3 bucket applies - delete the ECR registry prior to running `terraform destroy`

Failure to take these steps will mean terraform will delete everything except the S3 bucket and ECR registry. If that is the case, they will still need to be manually deleted, then `terraform destroy` ran again to ensure the terraform state file is correct and matches reality.