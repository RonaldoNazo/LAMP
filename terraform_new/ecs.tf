resource "aws_ecs_cluster" "example" {
  name = "${var.prefix}-ecs-cluster"
  tags = local.common_tags
}

resource "aws_ecs_task_definition" "phpmyadmin" {
  family                   = "${var.prefix}-phpmyadmin"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu = var.cpu
  memory = var.memory
  tags = local.common_tags
  container_definitions = jsonencode([
    {
      name      = "phpmyadmin"
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      environment = [{
        name  = "PMA_ARBITRARY"
        value = "1"
        }
      ]
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          protocol      = "tcp"
        }
      ]
    }
  ])

}

#LB 
resource "aws_lb" "load_balancer" {
  name               = "${var.prefix}-phpmyadmin-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
  tags = local.common_tags
}

resource "aws_lb_target_group" "foo" {
  name     = "${var.prefix}-phpmyadmin-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"
  stickiness {
    type = "lb_cookie"
    enabled = true
  }
  tags = local.common_tags
}

resource "aws_lb_listener" "bar" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foo.arn
  }
  depends_on = [ aws_lb_target_group.foo ]
  tags = local.common_tags  
}



resource "aws_ecs_service" "mongo" {
  name            = "phpmyadmin"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.phpmyadmin.arn
  desired_count   = 3
  launch_type = "FARGATE"
  tags = local.common_tags


  load_balancer {
    target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "phpmyadmin"
    container_port   = 80
  }

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

}

# Enable HTTPS for ALB
module "alb_https" {
  source = "./modules/https"
  application_name = var.prefix
  application_lb_arn = aws_lb.load_balancer.arn
  alb_target_group_arn = aws_lb_target_group.foo.arn
  common_tags = local.common_tags
  hosted_zone = var.hosted_zone
  
  
}