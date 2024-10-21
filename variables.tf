variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI Profile to use"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "root_volume_type" {
  description = "Root volume type (e.g., gp2 for General Purpose SSD)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "volume_size" {
  description = "Root volume size for the EC2 instance (in GB)"
  type        = number
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "key_name" {
  description = "SSH key name for EC2 instance access"
  type        = string
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "db_username" {
  description = "The database username"
  type        = string
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

