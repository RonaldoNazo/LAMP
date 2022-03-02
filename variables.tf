variable "name" {
  description = "Name to use on all resources created (VPC, ALB, etc)"
  type        = string
  default     = "Terraform"
}
variable "vpc_cidr_block" {
  description = "VPC CIDR Block "
  type        = string
  default     = "10.0.0.0/16"
}
variable "Subnets_cidr_block" {
  description = "VPC CIDR Block "
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24"]
}

variable "image_id" {
  description = "Image id of Instanced "
  type        = string
  default     = "ami-08e4e35cccc6189f4"
}
variable "key_name" {
  description = "Name Of key Pair that you want your instances to SSh into"
  type        = string
  default     = "key" #Key Name per Ec2-Pair
}
variable "autoscaling_capacity" {
  description = "Capacity of Instances [Min , Desired, Max]"
  type        = list(number)
  default     = [1,2,3]
}
variable "Https_certeficate" {
  description = "Certeficate arn of Load Balancer"
  type = string
  default = "arn:aws:acm:us-east-1:038855800565:certificate/97c98b89-c7e0-4748-af7c-d7b313392680" #vendos certefikaten
}
variable "RDS_Password" {
  description = "RDS Password "
  type = string
  default = "ronaldo1234" 
  sensitive = true
}