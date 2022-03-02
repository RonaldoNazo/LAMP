output "Web_DNS" {
  description = "Website Link of LoadBalancer"
  value       = "http://${aws_lb.Load_Balancer.dns_name}/phpMyAdmin"
}