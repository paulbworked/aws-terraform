# ─────────────────────────────────────────────────────────────────────────────
# Outputs — terraform-aws-ops-operations
# ─────────────────────────────────────────────────────────────────────────────

output "vpc_ops_id" {
  description = "Operations VPC ID"
  value       = aws_vpc.vpc_ops_prod_ew1.id
}

output "snet_app_id" {
  description = "App subnet ID"
  value       = aws_subnet.snet_app_prod_ew1.id
}

output "snet_data_id" {
  description = "Data subnet ID"
  value       = aws_subnet.snet_data_prod_ew1.id
}

output "snet_pep_id" {
  description = "Private endpoints subnet ID"
  value       = aws_subnet.snet_pep_prod_ew1.id
}

output "snet_ec2_id" {
  description = "EC2 subnet ID"
  value       = aws_subnet.snet_ec2_prod_ew1.id
}

output "snet_tgw_id" {
  description = "TGW subnet ID"
  value       = aws_subnet.snet_tgw_prod_ew1.id
}

output "tgw_attachment_id" {
  description = "TGW attachment ID — reference for Hub route table propagation confirmation"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw_att_ops_prod_ew1.id
}

output "ec2_test_instance_id" {
  description = "Test EC2 instance ID — use this in Session Manager to start a session"
  value       = aws_instance.ec2_test_ops_prod_ew1.id
}

output "ec2_test_private_ip" {
  description = "Test EC2 private IP"
  value       = aws_instance.ec2_test_ops_prod_ew1.private_ip
}
