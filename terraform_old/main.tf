provider "aws" {
  region = "us-east-1"
  access_key = "AKIA3FLDZRUY6QBVPVFU"
  secret_key = "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"
}
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "${var.name}-VPC"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-IGw"
  }
}
resource "aws_subnet" "Public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.Subnets_cidr_block[0]
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.name}-Public-Subnet-1"
  }
}
resource "aws_subnet" "Public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.Subnets_cidr_block[1]
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.name}-Public-Subnet-2"
  }
}
resource "aws_subnet" "Private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.Subnets_cidr_block[2]
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.name}-Private-Subnet-1"
  }
}
resource "aws_subnet" "Private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.Subnets_cidr_block[3]
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.name}-Private-Subnet-2"
  }
}
### IF Nat Gateway and Private Subnets Needed!
# resource "aws_eip" "eip" {
#   vpc = true
# }
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.Public1.id

#   tags = {
#     Name = "${var.name}-gw-NAT"
#   }
#   depends_on = [aws_internet_gateway.gw]
# }

resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.name}-RouteTable"
  }
}

### Private Route Table if you need private subnet! , Must have a NAt Gateway ###
# resource "aws_route_table" "Private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.nat.id

#   }

#   tags = {
#     Name = "${var.name}-Private RouteTable"
#   }
# }
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Public1.id
  route_table_id = aws_route_table.Public.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.Public2.id
  route_table_id = aws_route_table.Public.id
}
resource "aws_security_group" "EC2_SG" {
  name        = "${var.name}--Ec2-SG"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Http from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    self            = true
    security_groups = ["${aws_security_group.ALB_SG.id}"]
  }
  ingress {
    description = "SSh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_https&ssh"
  }
}
resource "aws_security_group" "ALB_SG" {
  name        = "cterraform-ALB-SG"
  description = "Allow http  traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "WEB from World"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# resource "aws_launch_configuration" "launch_conf" {
#   name                        = "${var.name}_LaunchConfig"
#   image_id                    = var.image_id
#   instance_type               = "t2.micro"
#   key_name                    = var.key_name
#   associate_public_ip_address = true
#   security_groups             = [aws_security_group.EC2_SG.id]
#   # user_data                   = filebase64("${path.module}/user-data-1.sh")  ##Problem!!!! RDS endpoint nuk futet si nje input ne shellscript.
#   user_data = <<EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum install httpd php php-mysql php-xml php-mbstring -y
# sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
# sudo usermod -a -G apache ec2-user
# sudo su - ec2-user
# groups
# sudo chown -R ec2-user:apache /var/www
# sudo chmod 2775 /var/www
# find /var/www -type d -exec sudo chmod 2775 {} \;
# find /var/www -type f -exec sudo chmod 0664 {} \;
# cd /var/www/html
# wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
# mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
# rm phpMyAdmin-latest-all-languages.tar.gz
# sudo cp phpMyAdmin/config.sample.inc.php phpMyAdmin/config.inc.php
# sed -i 's/localhost/${aws_db_instance.RDS.endpoint}/g'  phpMyAdmin/config.inc.php 
# sed -i "s/blowfish_secret'] = ''/blowfish_secret'] = '12345678901234567890123456789012'/g"  phpMyAdmin/config.inc.php
# sudo chmod 660 phpMyAdmin/config.inc.php
# sudo systemctl restart httpd
# EOF

#   depends_on = [aws_db_instance.RDS]
#   root_block_device {
#     volume_size = 20
#     encrypted   = true
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_launch_template" "launch_template" {
  name          = "${var.name}_LaunchTemplate"
  image_id      = var.image_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.EC2_SG.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum update -y
sudo yum install httpd php php-mysql php-xml php-mbstring -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo usermod -a -G apache ec2-user
sudo su - ec2-user
groups
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
sudo cp phpMyAdmin/config.sample.inc.php phpMyAdmin/config.inc.php
sed -i 's/localhost/${aws_db_instance.RDS.endpoint}/g'  phpMyAdmin/config.inc.php 
sed -i "s/blowfish_secret'] = ''/blowfish_secret'] = '12345678901234567890123456789012'/g"  phpMyAdmin/config.inc.php
sudo chmod 660 phpMyAdmin/config.inc.php
sudo systemctl restart httpd
EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}_Instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_db_instance.RDS]
}


resource "aws_autoscaling_group" "ASG" {
  vpc_zone_identifier = [aws_subnet.Public1.id, aws_subnet.Public2.id]
  desired_capacity    = var.autoscaling_capacity[1]
  max_size            = var.autoscaling_capacity[2]
  min_size            = var.autoscaling_capacity[0]
  target_group_arns   = ["${aws_lb_target_group.TG.arn}"]
  # launch_configuration = aws_launch_configuration.launch_conf.name
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  # launch_template {
  #   id      = aws_launch_template.LT.id
  #   version = "$Latest"
  # }

}
resource "aws_lb_target_group" "TG" {
  name     = "Terraform-TargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
}
resource "aws_lb" "Load_Balancer" {
  name               = "Terraform-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_SG.id]
  subnet_mapping {
    subnet_id = aws_subnet.Public1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.Public2.id
  }
  tags = {
    Name = "${var.name}-LoadBalancer"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Load_Balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

## RDS Creation
resource "aws_db_subnet_group" "RDS_SG" {
  name       = "main"
  subnet_ids = [aws_subnet.Private1.id, aws_subnet.Private2.id]

  tags = {
    Name = "My DB subnet group"
  }
}
variable "RDS_Password" {}
resource "aws_db_instance" "RDS" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  identifier             = "${var.name}rds"
  username               = "ronaldo"
  password               = var.RDS_Password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.RDS_SG.id
  vpc_security_group_ids = [aws_security_group.RDS_SG.id]
}
# resource "aws_db_security_group" "RDS_SG" {
#   name = "rds_sg"

#   ingress {
#     security_group_id = aws_security_group.EC2_SG.id
#   }
# }
resource "aws_security_group" "RDS_SG" {
  name        = "terraform-RDS-SG"
  description = "Allow mysql  traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Ingress mysql traffic"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    self            = true
    security_groups = ["${aws_security_group.EC2_SG.id}"]
  }

  egress {
    description      = "Egress mysql traffic"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.EC2_SG.id}"]
    ipv6_cidr_blocks = ["::/0"]
  }
}