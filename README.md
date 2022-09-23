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

7. At this point the infrastructure is all setup, however, we still need to deploy the Container to ECR to display the custom application.

This can be done 2 ways, either by using the provided `push-to-ecr.sh` script in the `build` folder, or (preferred) by setting up access to CodeCommit (AWS requires that the IAM User that intends to connect to codecommit upload their public SSH key to the User profile here:

`https://us-east-1.console.aws.amazon.com/iam/home#/users/<USERNAME>?section=security_credentials`

Where <USERNAME> is the User's name. To see all the available users (and click on the correct one as needed) follow this link:

`https://us-east-1.console.aws.amazon.com/iamv2/home#/users`

Then follow the instructions on the CodeCommit console on how to add the SSH config details to your ~/.ssh/config file (or equivalent if not Linux/Mac/WSL))
)

8. Connect to the URI presented in the terraform output from step 5 to view the website. Alternatively, review the ECS cluster in the AWS console.


### Task #2

For this second task, A rolling blue-green deployment can be triggered by either:

1. Making a change to the codecommit repository mentioned in Step #7 of Task #1, then follow the CodePipeline here:

`https://<AWS_REGION>.console.aws.amazon.com/codesuite/codepipeline/pipelines/example-main-Pipeline/view?region=<AWS_REGION>`

where <AWS_REGION> is the region specified in the `terraform.tfvars` file. By default this is `ap-southeast-1`, hence the link is: 

`https://ap-southeast-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/example-main-Pipeline/view?region=ap-southeast-1`

2. Using the `push-to-ecr.sh` file provided in the `build` sub-folder of this repository.

Please note, the preferred method is using the CodePipeline that levereges CloudWatch to detect the change to the repository, then levereges CodeCommit, CodeBuild, and CodeDeploy to deploy the change.

Also note: The CodePipeline will be **in an error state** until the CodeCommit repository has code pushed to it for the first time. This doesn't affect using the `push-to-ecr.sh` method, just something to be aware of.

Once code is pushed to CodeCommit, the CodePipeline can be watched at the link above in Step #1. Specifically the Blue/Green deployment is viewable by clicking the link in the **deploy** stage

<br /><br />

### Addendum

Outstanding Issues:

The S3 bucket created by terraform is subsequently modified by Codepipeline, and even with `force delete` = `true` enabled, the bucket is unable to be deleted by Terraform during a `destroy` run. This is an issue that with additional time could be solved, however, the current recommendation is to empty then delete the S3 bucket, either via the CLI or GUI, prior to running `terraform destroy`

Additionally there is an issue with deleting the created ECR registry, after an image has been deployed into it. Same advice as for the S3 bucket applies - delete the ECR registry prior to running `terraform destroy`

Failure to take these steps will mean terraform will delete everything except the S3 bucket and ECR registry. If that is the case, they will still need to be manually deleted, then `terraform destroy` ran again to ensure the terraform state file is correct and matches reality.