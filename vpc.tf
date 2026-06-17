###################################################
# CUSTOMER PROFILE VPC
###################################################

resource "aws_vpc" "customer" {
  cidr_block           = var.customer_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "customer-profile-vpc"
  }
}

resource "aws_subnet" "customer_public-1" {
  vpc_id                  = aws_vpc.customer.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # add this
  map_public_ip_on_launch = true
  tags                    = { Name = "cp-public-subnet-1" }
}

resource "aws_subnet" "customer_public-2" {
  vpc_id                  = aws_vpc.customer.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # different AZ
  map_public_ip_on_launch = true
  tags                    = { Name = "cp-public-subnet-2" }
}

resource "aws_subnet" "customer_private-1" {
  vpc_id            = aws_vpc.customer.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "cp-private-subnet-1" }
}

resource "aws_subnet" "customer_private-2" {
  vpc_id            = aws_vpc.customer.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "cp-private-subnet-2" }
}

resource "aws_internet_gateway" "customer" {
  vpc_id = aws_vpc.customer.id

  tags = {
    Name = "customer-igw"
  }
}

resource "aws_eip" "customer_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "customer" {
  allocation_id = aws_eip.customer_nat.id
  subnet_id     = aws_subnet.customer_public-1.id

  depends_on = [aws_internet_gateway.customer]
}

###################################################
# ACCOUNT VPC
###################################################

resource "aws_vpc" "account" {
  cidr_block           = var.account_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "account-vpc"
  }
}

resource "aws_subnet" "account_public-1" {
  vpc_id                  = aws_vpc.account.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "account-public-subnet-1" }
}

resource "aws_subnet" "account_public-2" {
  vpc_id                  = aws_vpc.account.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "account-public-subnet-2" }
}

resource "aws_subnet" "account_private-1" {
  vpc_id            = aws_vpc.account.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "account-private-subnet-1" }
}

resource "aws_subnet" "account_private-2" {
  vpc_id            = aws_vpc.account.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "account-private-subnet-2" }
}

resource "aws_internet_gateway" "account" {
  vpc_id = aws_vpc.account.id

  tags = {
    Name = "account-igw"
  }
}

resource "aws_eip" "account_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "account" {
  allocation_id = aws_eip.account_nat.id
  subnet_id     = aws_subnet.account_public-1.id

  depends_on = [aws_internet_gateway.account]
}

###################################################
# STATEMENT VPC
###################################################

resource "aws_vpc" "statement" {
  cidr_block           = var.statement_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "statement-vpc"
  }
}

resource "aws_subnet" "statement_public-1" {
  vpc_id                  = aws_vpc.statement.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "statement-public-subnet-1"
  }
}

resource "aws_subnet" "statement_public-2" {
  vpc_id                  = aws_vpc.statement.id
  cidr_block              = "172.16.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "statement-public-subnet-2"
  }
}

resource "aws_subnet" "statement_private-1" {
  vpc_id            = aws_vpc.statement.id
  cidr_block        = "172.16.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "statement-private-subnet-1"
  }
}

resource "aws_subnet" "statement_private-2" {
  vpc_id            = aws_vpc.statement.id
  cidr_block        = "172.16.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "statement-private-subnet-2"
  }
}

resource "aws_internet_gateway" "statement" {
  vpc_id = aws_vpc.statement.id

  tags = {
    Name = "statement-igw"
  }
}

resource "aws_eip" "statement_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "statement" {
  allocation_id = aws_eip.statement_nat.id
  subnet_id     = aws_subnet.statement_public-1.id

  depends_on = [aws_internet_gateway.statement]
}

###################################################
# SECURITY GROUPS
###################################################

resource "aws_security_group" "customer_bastion" {
  name   = "customer-bastion-sg"
  vpc_id = aws_vpc.customer.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["2.49.136.161/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "customer-bastion-sg"
  }
}

resource "aws_security_group" "customer" {
  name   = "customer-sg"
  vpc_id = aws_vpc.customer.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.customer_bastion.id]
  }

  ingress {
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "customer-sg"
  }
}

resource "aws_security_group" "account" {
  name   = "account-sg"
  vpc_id = aws_vpc.account.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.customer_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "account-sg"
  }
}

resource "aws_security_group" "statement" {
  name   = "statement-sg"
  vpc_id = aws_vpc.statement.id

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.account_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "statement-sg"
  }
}

resource "aws_security_group" "customer_alb" {
  name   = "customer-alb-sg"
  vpc_id = aws_vpc.customer.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "customer-alb-sg"
  }
}

resource "aws_security_group" "account_alb" {
  name   = "account-alb-sg"
  vpc_id = aws_vpc.account.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "account-alb-sg"
  }
}

resource "aws_security_group" "statement_alb" {
  name   = "statement-alb-sg"
  vpc_id = aws_vpc.statement.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "statement-alb-sg"
  }
}

resource "aws_lb" "customer" {
  name               = "customer-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.customer_alb.id]
  subnets            = [aws_subnet.customer_public-1.id, aws_subnet.customer_public-2.id]

  tags = {
    Name = "customer-alb"
  }
}

resource "aws_lb_target_group" "customer" {
  name        = "customer-tg"
  port        = 9091
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.customer.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "customer-tg"
  }
}

resource "aws_lb_listener" "customer_http" {
  load_balancer_arn = aws_lb.customer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer.arn
  }
}

resource "aws_lb_listener" "customer_https" {
  load_balancer_arn = aws_lb.customer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.customer.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer.arn
  }
}

resource "aws_lb" "account" {
  name               = "account-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.account_alb.id]
  subnets            = [aws_subnet.account_private-1.id, aws_subnet.account_private-2.id]

  tags = {
    Name = "account-alb"
  }
}

resource "aws_lb_target_group" "account" {
  name        = "account-tg"
  port        = 9092
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.account.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "account-tg"
  }
}

resource "aws_lb_listener" "account_http" {
  load_balancer_arn = aws_lb.account.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.account.arn
  }
}

resource "aws_lb" "statement" {
  name               = "statement-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.statement_alb.id]
  subnets            = [aws_subnet.statement_private-1.id, aws_subnet.statement_private-2.id]

  tags = {
    Name = "statement-alb"
  }
}

resource "aws_lb_target_group" "statement" {
  name        = "statement-tg"
  port        = 9093
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.statement.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "statement-tg"
  }
}

resource "aws_lb_listener" "statement_http" {
  load_balancer_arn = aws_lb.statement.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.statement.arn
  }
}

###################################################
# VPC PEERING
###################################################

resource "aws_vpc_peering_connection" "customer_account" {
  vpc_id      = aws_vpc.customer.id
  peer_vpc_id = aws_vpc.account.id
  auto_accept = true

  tags = {
    Name = "customer-account-peer"
  }
}

resource "aws_vpc_peering_connection" "account_statement" {
  vpc_id      = aws_vpc.account.id
  peer_vpc_id = aws_vpc.statement.id
  auto_accept = true

  tags = {
    Name = "account-statement-peer"
  }
}

###################################################
# ROUTE TABLES
###################################################

resource "aws_route_table" "customer_public" {
  vpc_id = aws_vpc.customer.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.customer.id
  }

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.customer_account.id
  }
}

resource "aws_route_table_association" "customer_public_1" {
  subnet_id      = aws_subnet.customer_public-1.id
  route_table_id = aws_route_table.customer_public.id
}

resource "aws_route_table_association" "customer_public_2" {
  subnet_id      = aws_subnet.customer_public-2.id
  route_table_id = aws_route_table.customer_public.id
}

resource "aws_route_table" "customer_private" {
  vpc_id = aws_vpc.customer.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.customer.id
  }

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.customer_account.id
  }
}

resource "aws_route_table_association" "customer_private_1" {
  subnet_id      = aws_subnet.customer_private-1.id
  route_table_id = aws_route_table.customer_private.id
}

resource "aws_route_table_association" "customer_private_2" {
  subnet_id      = aws_subnet.customer_private-2.id
  route_table_id = aws_route_table.customer_private.id
}


resource "aws_route_table" "account_public" {
  vpc_id = aws_vpc.account.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.account.id
  }

  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.customer_account.id
  }
}

resource "aws_route_table" "account_private" {
  vpc_id = aws_vpc.account.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.account.id
  }

  route {
    cidr_block                = "172.16.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.account_statement.id
  }

  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.customer_account.id
  }
}

resource "aws_route_table_association" "account_public_1" {
  subnet_id      = aws_subnet.account_public-1.id
  route_table_id = aws_route_table.account_public.id
}

resource "aws_route_table_association" "account_public_2" {
  subnet_id      = aws_subnet.account_public-2.id
  route_table_id = aws_route_table.account_public.id
}

resource "aws_route_table_association" "account_private_1" {
  subnet_id      = aws_subnet.account_private-1.id
  route_table_id = aws_route_table.account_private.id
}

resource "aws_route_table_association" "account_private_2" {
  subnet_id      = aws_subnet.account_private-2.id
  route_table_id = aws_route_table.account_private.id
}

resource "aws_route_table" "statement_public" {
  vpc_id = aws_vpc.statement.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.statement.id
  }
}

resource "aws_route_table" "statement_private" {
  vpc_id = aws_vpc.statement.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.statement.id
  }

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.account_statement.id
  }
}

resource "aws_route_table_association" "statement_public_1" {
  subnet_id      = aws_subnet.statement_public-1.id
  route_table_id = aws_route_table.statement_public.id
}

resource "aws_route_table_association" "statement_public_2" {
  subnet_id      = aws_subnet.statement_public-2.id
  route_table_id = aws_route_table.statement_public.id
}

resource "aws_route_table_association" "statement_private_1" {
  subnet_id      = aws_subnet.statement_private-1.id
  route_table_id = aws_route_table.statement_private.id
}

resource "aws_route_table_association" "statement_private_2" {
  subnet_id      = aws_subnet.statement_private-2.id
  route_table_id = aws_route_table.statement_private.id
}
