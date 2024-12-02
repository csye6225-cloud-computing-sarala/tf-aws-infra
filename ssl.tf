# # Obtain an SSL Certificate from ACM
# resource "aws_acm_certificate" "dev_certificate" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   tags = {
#     Name = "DevSSLCertificate"
#   }
# }

# resource "aws_acm_certificate_validation" "dev_cert_validation" {
#   certificate_arn         = aws_acm_certificate.dev_certificate.arn
#   validation_record_fqdns = ["_391fc4abea5071a473bd64669a534fca.dev.saralacsye6225.me."]
# }

# # # Reference the imported certificate
# # data "aws_acm_certificate" "demo_certificate" {
# #   domain   = var.domain_name
# #   statuses = ["ISSUED"] # Ensures only issued certificates are returned
# # }

# data "aws_availability_zones" "available" {
#   state = "available"
# }

//latest
# data "aws_acm_certificate" "imported_certificate" {
#   domain   = var.domain_name
#   statuses = ["ISSUED"] # Ensure you only get certificates that are already issued
# }

# locals {
#   validation_record_fqdns = var.aws_profile == "dev" ? ["_391fc4abea5071a473bd64669a534fca.dev.saralacsye6225.me."] : ["_d471c929bbd05f06f728065420e5cfbc.demo.saralacsye6225.me."]
# }

# resource "aws_acm_certificate" "certificate" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   tags = {
#     Name = "SSLCertificate"
#   }
# }

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.certificate.arn
#   validation_record_fqdns = local.validation_record_fqdns
# }

# data "aws_availability_zones" "available" {
#   state = "available"
# }


# # Conditional logic for creating or importing the certificate
# resource "aws_acm_certificate" "certificate" {
#   count             = var.environment == "dev" ? 1 : 0
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   tags = {
#     Name = "SSLCertificate"
#   }
# }

# # If the environment is 'demo', import the certificate
# data "aws_acm_certificate" "imported_certificate" {
#   count    = var.environment == "demo" ? 1 : 0
#   domain   = var.domain_name
#   statuses = ["ISSUED"]
# }

# # Validation resource for dev (only validate if it's a newly created certificate)
# resource "aws_acm_certificate_validation" "cert_validation" {
#   count                   = var.environment == "dev" ? 1 : 0
#   certificate_arn         = aws_acm_certificate.certificate[0].arn
#   validation_record_fqdns = local.validation_record_fqdns
# }

# # Skipping validation resource for demo because it's already imported and valid
# resource "aws_acm_certificate_validation" "demo_cert_validation" {
#   count           = var.environment == "demo" && data.aws_acm_certificate.imported_certificate[0].arn != "" ? 1 : 0
#   certificate_arn = data.aws_acm_certificate.imported_certificate[0].arn
#   # No validation_record_fqdns here because it's already imported and valid
# }
# # Define DNS validation records dynamically based on the environment
# locals {
#   validation_record_fqdns = var.environment == "dev" ? ["_391fc4abea5071a473bd64669a534fca.dev.saralacsye6225.me."] : [] # No validation for demo environment, hence empty list
# }

# Optional: Fetch AWS availability zones (just for context)
data "aws_availability_zones" "available" {
  state = "available"
}

# # Sample environment for testing purposes
# output "certificate_arn" {
#   value = var.environment == "dev" ? aws_acm_certificate.certificate[0].arn : data.aws_acm_certificate.imported_certificate[0].arn
# }

data "aws_acm_certificate" "cert_issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}
