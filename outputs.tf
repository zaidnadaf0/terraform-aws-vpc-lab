output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

output "nat_gateway_ip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the private web server"
  value       = aws_instance.web.id
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 web server (it has no public IP by design)"
  value       = aws_instance.web.private_ip
}

output "ssm_port_forward_command" {
  description = "AWS CLI command that tunnels the web server's port 80 to http://localhost:8080"
  value       = <<-EOT
    aws ssm start-session --target ${aws_instance.web.id} --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["80"],"localPortNumber":["8080"]}'
  EOT
}
