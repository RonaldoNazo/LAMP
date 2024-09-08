variable "prefix" {
  type        = string
  description = "value to be added as prefix"
}
variable "region" {
  type        = string
  description = "Region to deploy the resources"
}
variable "instance_class" {
  type        = string
  description = "Instance class to be used"
  default     = "db.t3.micro"
}
variable "hosted_zone" {
  type        = string
  description = "Hosted Zone Name" 
}

# ECS 
variable "cpu" {
  type        = number
  description = "CPU units for the task"
  default     = 1024
}
variable "memory" {
  type        = number
  description = "Memory for the task"
  default     = 2048
}
variable "image" {
  type        = string
  description = "Docker image to be used"
  default     = "docker.io/phpmyadmin:latest"
}
variable "port" {
  type        = number
  description = "Port to be used"
  default     = 80
}