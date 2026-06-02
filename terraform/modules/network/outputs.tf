output "subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.node.id
}

output "eip_allocation_id" {
  value = aws_eip.node.allocation_id
}

output "eip_public_ip" {
  value = aws_eip.node.public_ip
}
