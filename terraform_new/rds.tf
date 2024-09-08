module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.prefix}-db"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = "demodb"
  username = "user"
  manage_master_user_password = false
  password = "ronaldo123"
  port     = "3306"
  

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db.id]


  tags = local.common_tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false
}

