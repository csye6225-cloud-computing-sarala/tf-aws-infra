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

variable "environment" {
  description = "Environment for the instance, either 'dev' or 'demo'"
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

variable "db_allocated_storage" {
  description = "The allocated storage size in GB for the RDS instance"
  type        = number
}

variable "db_storage_type" {
  description = "The type of storage for the RDS instance (e.g., gp2)"
  type        = string
}

variable "db_engine" {
  description = "The database engine (e.g., postgres)"
  type        = string
}

variable "db_engine_version" {
  description = "The version of the database engine (e.g., 13.16 for PostgreSQL)"
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance (e.g., db.t3.micro)"
  type        = string
}

variable "db_parameter_group_family" {
  description = "The parameter group family (e.g., postgres13 for PostgreSQL version 13.x)"
  type        = string
}

variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "health_check_interval" {
  description = "health check interval"
  type        = string
}

variable "scale_up_adjustment" {
  description = "scale adjustment for scale up"
  type        = string
}

variable "scale_up_cooldown" {
  description = "cooldown for scale up"
  type        = string
}

variable "cpu_high_threshold" {
  description = "threshold for cpu high"
  type        = string
}

variable "metric_name" {
  description = "name for metric"
  type        = string
}

variable "scale_down_adjustment" {
  description = "scale adjustment for scale down"
  type        = string
}

variable "scale_down_cooldown" {
  description = "cooldown for scale down"
  type        = string
}

variable "cpu_low_threshold" {
  description = "threshold for cpu low"
  type        = string
}

variable "db_host" {
  description = "Database host"
}

variable "db_port" {
  description = "Database port"
  default     = 5432
}

variable "mailgun_domain" {
  description = "Your Mailgun domain"
  type        = string
}

variable "mailgun_api_key" {
  description = "Your Mailgun API key"
  type        = string
  sensitive   = true
}


variable "email_sender" {
  description = "Verified SES email sender address"
  type        = string
}
