resource "aws_route53_zone" "public" {
  provider = aws.shared
  name     = var.public_zone_name

  tags = {
    Application = "enterprise-platform"
    Environment = "shared"
    ManagedBy   = "terraform"
    Owner       = "cloud-platform"
  }
}

resource "aws_route53_zone" "private" {
  provider = aws.dev
  name     = "internal.dev.${var.public_zone_name}"

  vpc {
    vpc_id = aws_vpc.this.id
  }

  tags = {
    Name = "${local.name_prefix}-private-zone"
  }
}

resource "aws_acm_certificate" "app" {
  provider          = aws.dev
  domain_name       = "app.dev.${var.public_zone_name}"
  validation_method = "DNS"

  subject_alternative_names = [
    "api.dev.${var.public_zone_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validation" {
  provider = aws.shared

  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.public.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "app" {
  provider                = aws.dev
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}