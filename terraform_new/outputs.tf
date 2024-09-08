output "phpmyadmin-url" {
  value = module.alb_https.https_endpoint
}
