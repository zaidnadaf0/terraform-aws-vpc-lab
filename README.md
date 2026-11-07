# Terraform AWS VPC Lab ☁️

Infrastructure-as-Code lab that builds a two-tier AWS VPC — public and private subnets, an Internet Gateway, a NAT Gateway for private egress, and a web server with no public IP — using **Terraform**.

[![Terraform](https://img.shields.io/badge/Terraform-%E2%89%A51.5-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io)
[![AWS](https://img.shields.io/badge/AWS-VPC%20%C2%B7%20EC2%20%C2%B7%20IAM-232F3E?logo=amazonaws&logoColor=white)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

## Architecture

```
VPC 10.0.0.0/16
├── Public subnet  10.0.1.0/24  (us-east-1a)
│   ├── Internet Gateway  ──► 0.0.0.0/0
│   └── NAT Gateway (Elastic IP)
└── Private subnet 10.0.2.0/24  (us-east-1b)
    ├── Route: 0.0.0.0/0 ──► NAT Gateway   (outbound only)
    └── EC2 web server (Amazon Linux 2, httpd, no public IP)
        └── IAM instance profile ──► SSM Session Manager
```

The design point is deliberate: the web server sits in the **private** subnet and reaches the internet only *outbound* through the NAT Gateway. There is no inbound path from the internet, and no public IP. Access is through AWS Systems Manager instead of a bastion host.

## What gets created

| Resource | Notes |
|---|---|
| `aws_vpc` | DNS support and hostnames enabled, `10.0.0.0/16` |
| `aws_subnet.public` | `10.0.1.0/24`, auto-assigns public IPs |
| `aws_subnet.private` | `10.0.2.0/24`, hosts the web server |
| `aws_internet_gateway` | Attached to the VPC |
| `aws_eip` + `aws_nat_gateway` | NAT in the public subnet for private egress |
| Route tables | Public → IGW, private → NAT, each associated with its subnet |
| `aws_security_group` | HTTP and SSH, **scoped to the VPC by default** |
| IAM role + instance profile | `AmazonSSMManagedInstanceCore` for Session Manager |
| `aws_instance` | Amazon Linux 2, `t2.micro`, Apache (`httpd`) via `user_data` |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.5 (tested with 1.9.8)
- AWS CLI v2, configured with credentials (`aws configure` or `AWS_PROFILE`)
- Permissions to create VPC, EC2, EIP, IAM role and route table resources

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Optional overrides:

```bash
cp terraform.tfvars.example terraform.tfvars   # git-ignored
```

### Reaching the private web server

The instance has no public IP, so there is nothing to `curl` from your laptop directly. Use the SSM port-forwarding command this configuration outputs:

```bash
aws ssm start-session \
  --target "$(terraform output -raw ec2_instance_id)" \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["80"],"localPortNumber":["8080"]}'
```

With the session open, `http://localhost:8080` serves the page written by `user_data`. No SSH key, no bastion, no inbound security-group rule required. (Requires the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html).)

### Outputs

| Output | Description |
|---|---|
| `vpc_id` | VPC ID |
| `public_subnet_id` / `private_subnet_id` | Subnet IDs |
| `nat_gateway_ip` | Elastic IP of the NAT Gateway |
| `ec2_instance_id` | Instance ID used for SSM sessions |
| `ec2_private_ip` | Private IP of the web server |
| `ssm_port_forward_command` | Ready-to-paste port-forwarding command |

### Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Region to deploy into |
| `project_name` | `vpc-lab` | Prefix for resource names and tags |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR (validated) |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR (validated) |
| `private_subnet_cidr` | `10.0.2.0/24` | Private subnet CIDR (validated) |
| `instance_type` | `t2.micro` | Free Tier eligible instance type |
| `allowed_http_cidr` | `10.0.0.0/16` | Who may reach port 80 |
| `allowed_ssh_cidr` | `10.0.0.0/16` | Who may reach port 22 |

All CIDR variables validate with `can(cidrhost(...))`, so a typo fails at plan time rather than half-applying.

## Cost warning

A NAT Gateway is billed hourly plus data processing, and the Elastic IP is billed while attached. Delete the stack when you are done:

```bash
terraform destroy
```

Nothing in this repository is left running by default — see the honesty note below.

## Continuous integration

`.github/workflows/terraform.yml` runs on every push and pull request that touches `*.tf`:

1. `terraform fmt -check -recursive -diff`
2. `terraform init -backend=false` (no state backend, **no AWS credentials**)
3. `terraform validate`

That proves the configuration is syntactically valid and internally consistent without touching an AWS account. It does not prove the resources can be created — that requires real credentials and would cost money.

## Verification status

This configuration has been **formatted and validated locally with Terraform 1.9.8** (`terraform fmt`, `terraform init -backend=false`, `terraform validate`), and the same checks run in CI. It has **not** been applied to a live AWS account from this repository, so no deployed infrastructure or screenshots of live resources are claimed here.

## Project structure

```
terraform-aws-vpc-lab/
├── main.tf                  # provider, VPC, subnets, gateways, routes, SG, IAM, EC2
├── variables.tf             # inputs with CIDR validation
├── outputs.tf               # IDs, private IP, SSM port-forward command
├── terraform.tfvars.example # sample overrides
├── .github/workflows/terraform.yml
└── LICENSE
```

## License

[Apache License 2.0](LICENSE)

## Author

**Mohammed Zaid Nadaf** — [GitHub](https://github.com/zaidnadaf0) · [LinkedIn](https://www.linkedin.com/in/mohammed-zaid-nadaf-1333b0368/)
