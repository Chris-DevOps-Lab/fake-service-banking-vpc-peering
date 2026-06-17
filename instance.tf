resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.customer_public-1.id
  vpc_security_group_ids      = [aws_security_group.customer_bastion.id]

  tags = {
    Name = "bastion-host"
  }
}

###############################################
# Customer App Instances
###############################################
resource "aws_instance" "customer_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.customer_private-1.id
  vpc_security_group_ids      = [aws_security_group.customer.id]

  user_data = templatefile("${path.module}/scripts/customer-profile.sh", {
    account_alb_dns = aws_lb.account.dns_name
  })

  tags = { Name = "customer-app-1" }
}

resource "aws_instance" "customer_app_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.customer_private-2.id
  vpc_security_group_ids      = [aws_security_group.customer.id]

  user_data = templatefile("${path.module}/scripts/customer-profile.sh", {
    account_alb_dns = aws_lb.account.dns_name
  })

  tags = { Name = "customer-app-2" }
}

###############################################
# Account App Instances
###############################################
resource "aws_instance" "account_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.account_private-1.id
  vpc_security_group_ids      = [aws_security_group.account.id]

  user_data = templatefile("${path.module}/scripts/account.sh", {
    statement_alb_dns = aws_lb.statement.dns_name
  })

  tags = { Name = "account-app-1" }
}

resource "aws_instance" "account_app_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.account_private-2.id
  vpc_security_group_ids      = [aws_security_group.account.id]

  user_data = templatefile("${path.module}/scripts/account.sh", {
    statement_alb_dns = aws_lb.statement.dns_name
  })

  tags = { Name = "account-app-2" }
}

###############################################
# Statement App Instances
###############################################
resource "aws_instance" "statement_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.statement_private-1.id
  vpc_security_group_ids      = [aws_security_group.statement.id]

  user_data = file("${path.module}/scripts/statement.sh")

  tags = { Name = "statement-app-1" }
}

resource "aws_instance" "statement_app_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.fake_service_app.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.statement_private-2.id
  vpc_security_group_ids      = [aws_security_group.statement.id]

  user_data = file("${path.module}/scripts/statement.sh")

  tags = { Name = "statement-app-2" }
}

###############################################
# Target Group Attachments
###############################################
resource "aws_lb_target_group_attachment" "customer_1" {
  target_group_arn = aws_lb_target_group.customer.arn
  target_id        = aws_instance.customer_app.id
  port             = 9091
}

resource "aws_lb_target_group_attachment" "customer_2" {
  target_group_arn = aws_lb_target_group.customer.arn
  target_id        = aws_instance.customer_app_2.id
  port             = 9091
}

resource "aws_lb_target_group_attachment" "account_1" {
  target_group_arn = aws_lb_target_group.account.arn
  target_id        = aws_instance.account_app.id
  port             = 9092
}

resource "aws_lb_target_group_attachment" "account_2" {
  target_group_arn = aws_lb_target_group.account.arn
  target_id        = aws_instance.account_app_2.id
  port             = 9092
}

resource "aws_lb_target_group_attachment" "statement_1" {
  target_group_arn = aws_lb_target_group.statement.arn
  target_id        = aws_instance.statement_app.id
  port             = 9093
}

resource "aws_lb_target_group_attachment" "statement_2" {
  target_group_arn = aws_lb_target_group.statement.arn
  target_id        = aws_instance.statement_app_2.id
  port             = 9093
}