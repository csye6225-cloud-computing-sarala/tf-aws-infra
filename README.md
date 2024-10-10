**Terraform AWS Infrastructure Setup**
This repository contains Terraform configurations to set up AWS networking infrastructure, including Virtual Private Cloud (VPC), subnets, route tables, and an internet gateway. The setup is designed to work with Terraform, allowing Infrastructure as Code (IaC) management for seamless provisioning of AWS resources.

**Project Overview**
The project automates the setup of AWS networking resources using Terraform. It includes:

VPC: A Virtual Private Cloud (VPC) that acts as the isolated network in the AWS cloud.
Subnets: Three public and three private subnets, each in a different availability zone.
Internet Gateway: Attached to the VPC for internet access to public subnets.
Route Tables:
Public route table with routes to the internet gateway.
Private route table for private subnets.
Prerequisites
To run the project locally, you will need:

Terraform installed on your machine.
AWS CLI installed and configured with the appropriate profiles for access.
An AWS account with IAM permissions to create VPCs, subnets, and route tables.

**Prerequisites**
Before you begin, ensure you have the following installed on your local machine:

- Terraform (v1.3.0 or later)
- AWS CLI
- An AWS account with appropriate IAM permissions
  
You must also configure AWS profiles for both the dev and demo environments:
````bash
aws configure --profile dev
aws configure --profile demo
````

**Setup Instructions**

*Clone the Repository*
````bash
git clone <repo_url>
cd <repo>
````

*Set Up Terraform*
Make sure Terraform is installed by running:

````bash
terraform --version
````

*Set Up tfvars Files*
You need to define values for your environment variables in .tfvars files. Below are sample placeholders for both dev and demo environments:
````bash
aws_profile     = "dev"                 
aws_region      = "<YOUR_DEV_REGION>"   

vpc_cidr        = "<YOUR_DEV_VPC_CIDR>" 

public_subnets  = [                    
  "<YOUR_DEV_PUBLIC_SUBNET_1_CIDR>",    
  "<YOUR_DEV_PUBLIC_SUBNET_2_CIDR>",    
  "<YOUR_DEV_PUBLIC_SUBNET_3_CIDR>"     
]

private_subnets = [                     
  "<YOUR_DEV_PRIVATE_SUBNET_1_CIDR>",   
  "<YOUR_DEV_PRIVATE_SUBNET_2_CIDR>",   
  "<YOUR_DEV_PRIVATE_SUBNET_3_CIDR>"    
]

availability_zones = [                  
  "<YOUR_DEV_AZ_1>",                    
  "<YOUR_DEV_AZ_2>",                    
  "<YOUR_DEV_AZ_3>"                     
]
````

*Initialize Terraform*
Run the following command to initialize Terraform and download necessary provider plugins:
````bash
terraform init
````

Format the Terraform Code
Ensure that your Terraform files are formatted according to Terraform's standard:

````bash
terraform fmt -recursive
````

*Plan and Apply Changes*
You can now plan and apply the infrastructure for each environment.

For dev environment:
Plan:
````bash
terraform plan -var-file="dev.tfvars"
````
Apply:
````bash
terraform apply -var-file="dev.tfvars"
````

For demo environment:
Plan:
````bash
terraform plan -var-file="demo.tfvars"
````
Apply:
````bash
terraform apply -var-file="demo.tfvars"
````

*Destroy the Infrastructure*
When you're done with the infrastructure, you can destroy it to avoid unnecessary costs.

For dev environment:
````bash
terraform destroy -var-file="dev.tfvars"
````

For demo environment:
````bash
terraform destroy -var-file="demo.tfvars"
````

*Test Runs*
Test Run #1
Test Run #2
Test Run #3