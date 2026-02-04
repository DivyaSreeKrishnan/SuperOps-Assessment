# Build a Load-Balanced Web Server Environment
## Description

This project is created for assessment purpose.
The primary deployment folder provisions all required AWS infrastructure using Terraform, following Infrastructure as Code (IaC).

## Architecture Overview
### Components Created
- VPC: 10.0.0.0/16
- 2 Public Subnets (Multi-AZ: us-east-1a, us-east-1b)
- Internet Gateway
- Route Table with internet access
- Application Load Balancer (ALB)
- Target Group with health checks
- 2 EC2 instances (Amazon Linux)
- Security Groups
    - ALB Security Group
    - Web Server Security Group
- Nginx installed automatically using userdata.sh

### Prerequisites
- AWS Account
- Terraform 
- AWS CLI
- Git
- IAM user or root credentials configured locally

## AWS Authentication
Configure AWS credentials locally using:
- aws configure

## Provide the following details:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (us-east-1)
- Output format (json)

## Example Usage
- Open a VS Code terminal and navigate to the Terraform deployment directory.s
Run the following commands:
``` text
terraform init
terraform plan
terraform apply
terraform destroy
```

## Verify Deployment (AWS Console)
After running terraform apply, verify the following in the AWS Console:
- EC2
- Two running instances
- Load Balancer
- Application Load Balancer (active state)
- Healthy targets in the target group

## Test the Application
Copy the ALB DNS name from the Terraform output or AWS Console

Open it in a browser:
- http://ALB-DNS-NAME

You should see the Nginx welcome page.

## Destroy Infrastructure
After verification, clean up all resources to avoid unnecessary costs:
- terraform destroy