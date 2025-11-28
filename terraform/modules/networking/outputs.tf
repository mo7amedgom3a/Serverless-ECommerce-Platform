output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "ec2_rds_sg_id" {
  description = "ID of the EC2 to RDS security group"
  value       = aws_security_group.ec2_rds_sg.id
}

output "lambda_rds_sg_id" {
  description = "ID of the Lambda to RDS security group"
  value       = aws_security_group.lambda_rds_sg.id
}

output "rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}
