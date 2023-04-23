#output "ec2_ipaddress" {
#  value = aws_eip.ec2_public[0].public_ip
#}

output "ec2_instance_arn" {
  value = aws_instance.ec2_template.arn
}

output ec2_network_interface_id {
  value       = aws_instance.ec2_template.primary_network_interface_id
}
