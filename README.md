# Terraform AWS Fake Banking Platform

## Overview

This project demonstrates the deployment of a multi-service banking platform on AWS using Terraform Infrastructure as Code (IaC).

The platform consists of three banking microservices:

* Customer Profile Service
* Account Service
* Statement Service

The infrastructure is designed using multiple VPCs connected through VPC Peering, Application Load Balancers (ALB), EC2 instances, Security Groups, Route Tables, and Terraform-managed resources.

This project was built to demonstrate practical cloud infrastructure engineering skills, including network design, infrastructure automation, load balancing, service communication, and AWS resource provisioning.

---

## Architecture Diagram

```text
                                  Internet
                                      |
                                      |
                                      v
                     +--------------------------------+
                     | Application Load Balancer (ALB)|
                     +--------------------------------+
                                      |
                                      |
                                      v

        +------------------------------------------------------+
        |                  Customer Service                    |
        |                  EC2 Instance                        |
        +------------------------------------------------------+
                                      |
                                      |
                                      v

        +------------------------------------------------------+
        |                   Account Service                    |
        |                   EC2 Instance                       |
        +------------------------------------------------------+
                                      |
                                      |
                                      v

        +------------------------------------------------------+
        |                  Statement Service                   |
        |                   EC2 Instance                       |
        +------------------------------------------------------+

==================================================================

                    AWS Network Architecture

    +--------------------+        +--------------------+
    |    Customer VPC    |<------>|    Account VPC     |
    +--------------------+        +--------------------+
               ^                            ^
               |                            |
               +------------+---------------+
                            |
                            v
                  +--------------------+
                  |   Statement VPC    |
                  +--------------------+

              Connected using VPC Peering
```

---
## Architecture Diagram
<img width="1536" height="1024" alt="ChatGPT Image Jun 18, 2026, 03_22_39 PM" src="https://github.com/user-attachments/assets/73d996f9-fc22-40cd-99d2-6fa1f556d359" />


## AWS Services Used
* Amazon VPC
* VPC Peering
* Application Load Balancer (ALB)
* EC2 Instances
* Security Groups
* Route Tables
* Subnets
* Internet Gateway
* NAT Gateway
* Terraform
* AWS CLI

---

## Project Structure

```text
.
├── account.tf
├── customer.tf
├── statement.tf
├── vpc.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── provider.tf
├── terraform.tfvars
├── user-data/
└── README.md
```

---

## Features

### Infrastructure as Code

Entire AWS infrastructure is provisioned using Terraform.

### Multi-VPC Architecture

Separate VPCs are used for:

* Customer Service
* Account Service
* Statement Service

### VPC Peering

Services communicate securely through VPC Peering connections.

### Application Load Balancer

Customer requests are routed through an Application Load Balancer.

### Security Groups

Controlled inbound and outbound traffic between services.

### Service Chaining

Customer Service communicates with:

Customer Service

↓

Account Service

↓

Statement Service

Result:

```text
Customer Profile Service -> Account Service -> Statement Service: transaction statements ready
```

---

## Deployment

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Review Execution Plan

```bash
terraform plan
```

### Deploy Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

## Verification

Check deployed resources:

```bash
terraform state list
```

Check Load Balancers:

```bash
aws elbv2 describe-load-balancers --region us-east-1
```

Access Application:

```text
http://<ALB-DNS-NAME>
```

Example:

```text
http://fake-service-banking-customer-1726939308.us-east-1.elb.amazonaws.com
```

---

## Skills Demonstrated

* Terraform Infrastructure as Code
* AWS Networking
* VPC Design
* VPC Peering
* Security Group Management
* Load Balancing
* Route Tables
* Subnet Design
* EC2 Deployment
* Cloud Infrastructure Automation
* Infrastructure Troubleshooting

---

## Future Improvements

* Route53 Integration
* ACM SSL Certificate
* HTTPS Listener
* Auto Scaling Group
* CloudWatch Monitoring
* AWS WAF
* GitHub Actions CI/CD
* Terraform Modules Refactoring

---

## Author

Aung Paing Min Thant

Cloud Infrastructure Engineer | DevOps Enthusiast

GitHub:
https://github.com/Chris-DevOps-Lab
