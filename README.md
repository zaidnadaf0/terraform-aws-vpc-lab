# Terraform AWS VPC Lab ☁️

Infrastructure-as-Code lab that provisions a production-ready AWS VPC with public/private subnets, NAT gateway, and an EC2 web server using **Terraform**.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│                 AWS VPC                      │
│              10.0.0.0/16                     │
│                                              │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │ Public Subnet │    │ Private Subnet   │   │
│  │ 10.0.1.0/24  │    │ 10.0.2.0/24      │   │
│  │              │    │                  │   │
│  │ ┌──────────┐ │    │ ┌──────────────┐ │   │
│  │ │ Internet │ │    │ │  EC2 Web     │ │   │
│  │ │ Gateway  │◄├────┤►  Server      │ │   │
│  │ └──────────┘ │    │ │ (private)    │ │   │
│  │              │    │ └──────────────┘ │   │
│  │ ┌──────────┐ │    │        ▲         │   │
│  │ │ NAT GW   ├┼────┼────────┘         │   │
│  │ └──────────┘ │    │                  │   │
│  └──────────────┘    └──────────────────┘   │
└─────────────────────────────────────────────┘
```

## 📋 What Gets Created

- VPC with CIDR `10.0.0.0/16`
- Public subnet with Internet Gateway
- Private subnet with NAT Gateway
- Route tables for both subnets
- Security group allowing HTTP (80) and SSH (22)
- EC2 instance (t2.micro) with Apache web server

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) ≥ 1.5
- AWS CLI configured (`aws configure`)
- An AWS account with permissions to create VPC resources

### Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
```

### Verify

After apply completes, Terraform outputs the public IP of the EC2 instance:

```bash
curl http://$(terraform output -raw ec2_public_ip)
```

You should see the Apache default page.

### Cleanup

```bash
terraform destroy
```

> ⚠️ Always run `terraform destroy` when done to avoid ongoing AWS charges.

## 📁 Project Structure

```
terraform-aws-vpc-lab/
├── main.tf          # VPC, subnets, IGW, NAT, security group, EC2
├── variables.tf     # Configurable inputs (region, CIDR, instance type)
├── outputs.tf       # Exported values (VPC ID, public IP)
├── terraform.tfvars # Your variable overrides (not committed)
└── README.md
```

## 🔧 Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR |
| `private_subnet_cidr` | `10.0.2.0/24` | Private subnet CIDR |
| `instance_type` | `t2.micro` | EC2 instance type (free tier eligible) |

## 📄 License

[Apache License 2.0](LICENSE)

## 🙋 Author

**Mohammed Zaid Nadaf** — CS Engineering Student · Aspiring Cloud Engineer
