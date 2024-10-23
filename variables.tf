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

variable "db_allocated_storage" {
  description = "The allocated storage size in GB for the RDS instance"
  type        = number
  # default     = 20
}

variable "db_storage_type" {
  description = "The type of storage for the RDS instance (e.g., gp2)"
  type        = string
  # default     = "gp2"
}

variable "db_engine" {
  description = "The database engine (e.g., postgres)"
  type        = string
  # default     = "postgres"
}

variable "db_engine_version" {
  description = "The version of the database engine (e.g., 13.16 for PostgreSQL)"
  type        = string
  # default     = "13.16"
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance (e.g., db.t3.micro)"
  type        = string
  # default     = "db.t3.micro"
}

variable "db_parameter_group_family" {
  description = "The parameter group family (e.g., postgres13 for PostgreSQL version 13.x)"
  type        = string
  # default     = "postgres13"
}
