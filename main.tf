# terraform {
#   required_providers {
#     random = {
#       source  = "hashicorp/random"
#       version = "~> 3.0"
#     }
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.5"
#     }
#   }
# }
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0.0, <6.0.0"
    }
  }
  required_version = ">= 1.2.0"
}
