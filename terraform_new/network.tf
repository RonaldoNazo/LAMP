module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = local.common_tags
}

# ALB SG 
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb"
  description = "Allow all traffic to ALB"
  vpc_id      = module.vpc.vpc_id
  tags = local.common_tags

}

## SG rules for ALB 
resource "aws_security_group_rule" "alb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "https_alb_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

## SG rules for ALB egress
resource "aws_security_group_rule" "alb_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ecs.id
}

# ECS SG

resource "aws_security_group" "ecs" {
  name        = "${var.prefix}-ecs"
  description = "Allow all traffic to ECS"
  vpc_id      = module.vpc.vpc_id
  tags = local.common_tags  

}
## SG Rules 

resource "aws_security_group_rule" "ecs_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.alb.id
}
resource "aws_security_group_rule" "ecs_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ecs.id
  cidr_blocks = ["0.0.0.0/0"]
}

# RDS SG    

resource "aws_security_group" "db" {
  name        = "${var.prefix}-db"
  description = "Allow all traffic to RDS"
  vpc_id      = module.vpc.vpc_id
  tags = local.common_tags
}

## SG Rules
resource "aws_security_group_rule" "db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ecs.id
}

