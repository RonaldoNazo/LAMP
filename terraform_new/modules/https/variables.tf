variable "application_name" {
  type = string
  description = "Application name you want to create the endpoint, e.g. 'ctapp1'"
}

variable "application_lb_arn" {
  type = string
  description = "Application Load balancer arn"
}

variable "alb_target_group_arn" {
  type = string
  description = "target group arn to forward traffic to"
}
variable "common_tags" {
  description = "Naming Convention"
  type        = map(any)
}
variable "hosted_zone" {
  description = "Hosted Zone Name"
  type        = string
}