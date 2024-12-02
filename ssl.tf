data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_acm_certificate" "cert_issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}
