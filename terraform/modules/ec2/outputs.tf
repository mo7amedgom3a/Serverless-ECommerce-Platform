output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.rds_admin.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.rds_admin.public_ip
}

output "ec2_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}
