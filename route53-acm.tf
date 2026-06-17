###################################################
# ACM CERTIFICATE
###################################################

resource "aws_acm_certificate" "customer" {
  domain_name       = "fake-service.swundev.online"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "fake-service-cert"
  }
}

###################################################
# ROUTE 53
###################################################

resource "aws_route53_zone" "main" {
  name = "swundev.online"

  tags = {
    Name = "swundev-zone"
  }
}

resource "aws_route53_record" "customer_alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "fake-service.swundev.online"
  type    = "A"

  alias {
    name                   = aws_lb.customer.dns_name
    zone_id                = aws_lb.customer.zone_id
    evaluate_target_health = true
  }
}

# DNS validation record for ACM
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.customer.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "customer" {
  certificate_arn         = aws_acm_certificate.customer.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

###################################################
# HTTPS LISTENER (update existing variable)
###################################################

# Pass the validated cert ARN to the existing HTTPS listener
# Update your variables.tf or tfvars:
# customer_alb_certificate_arn = aws_acm_certificate_validation.customer.certificate_arn