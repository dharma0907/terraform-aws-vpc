output "azs_info" {
  value       = data.aws_availability_zones.available.names
}

# giving output of vpc ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# giving output of public subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

# giving output of private subnet IDs
output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database_subnet[*].id
}