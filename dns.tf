# data "aws_route53_zone" "selected" {
#   name         = var.domain_name
#   private_zone = false
# }

# // DNS Record to Point to the Load Balancer
# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = var.domain_name
#   type    = "A"
#   alias {
#     name                   = aws_lb.app_lb.dns_name
#     zone_id                = aws_lb.app_lb.zone_id
#     evaluate_target_health = true
#   }
# }
data "aws_route53_zone" "selected" {
  name = var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = data.aws_route53_zone.selected.name
  type    = "A"
  ttl     = "60"
  records = [aws_instance.app_instance.public_ip]
}
