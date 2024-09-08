
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.application_name}.${local.public_zone}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.example.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}

###ALB Set https

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = var.application_lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.example.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.alb_target_group_arn
  }
}

resource "aws_route53_record" "www-live" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = "${var.application_name}.${local.public_zone}"
  type    = "CNAME"
  ttl     = 60
  records        = ["${local.aws_lb_endpoint}"]
}

