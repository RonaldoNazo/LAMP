output "https_endpoint" {
  description = "Application Load Balancer HTTPS URL"
  value = "https://${aws_route53_record.www-live.fqdn}/"
}