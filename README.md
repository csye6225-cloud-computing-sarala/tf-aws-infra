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


**Setup Instructions**

*Clone the Repository*
````bash
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo

*Initialize and Plan the Terraform Setup*
````bash
terraform init

*Plan Terraform Changes*
````bash
terraform plan

*Apply Terraform Changes*
````bash
terraform apply
