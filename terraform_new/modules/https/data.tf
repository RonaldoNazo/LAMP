data "aws_route53_zone" "example" {
  name         = local.public_zone
  private_zone = false
}

data "aws_lb" "example" {
  arn  = var.application_lb_arn
}

locals {
  aws_lb_endpoint = data.aws_lb.example.dns_name
  public_zone = var.hosted_zone
} 


