variable "customer_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "account_vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "statement_vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "customer_alb_certificate_arn" {
  description = "Optional ACM certificate ARN for customer ALB HTTPS listener. Leave blank to disable HTTPS."
  default     = ""
}
