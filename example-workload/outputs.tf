# ─────────────────────────────────────────────────────────────────────────────
# Outputs — terraform-aws-bedrock-prod
# ─────────────────────────────────────────────────────────────────────────────

output "vpc_br_prod_id" {
  description = "Bedrock Prod VPC ID"
  value       = aws_vpc.vpc_br_prod_ew1.id
}

output "snet_app_a_id" {
  description = "App subnet AZ-a ID"
  value       = aws_subnet.snet_app_br_prod_ew1_a.id
}

output "snet_app_b_id" {
  description = "App subnet AZ-b ID"
  value       = aws_subnet.snet_app_br_prod_ew1_b.id
}

output "snet_data_a_id" {
  description = "Data subnet AZ-a ID"
  value       = aws_subnet.snet_data_br_prod_ew1_a.id
}

output "snet_data_b_id" {
  description = "Data subnet AZ-b ID"
  value       = aws_subnet.snet_data_br_prod_ew1_b.id
}

output "snet_pep_a_id" {
  description = "Private endpoints subnet AZ-a ID"
  value       = aws_subnet.snet_pep_br_prod_ew1_a.id
}

output "snet_pep_b_id" {
  description = "Private endpoints subnet AZ-b ID"
  value       = aws_subnet.snet_pep_br_prod_ew1_b.id
}

output "snet_ec2_a_id" {
  description = "EC2 subnet AZ-a ID"
  value       = aws_subnet.snet_ec2_br_prod_ew1_a.id
}

output "snet_ec2_b_id" {
  description = "EC2 subnet AZ-b ID"
  value       = aws_subnet.snet_ec2_br_prod_ew1_b.id
}

output "snet_tgw_a_id" {
  description = "TGW subnet AZ-a ID"
  value       = aws_subnet.snet_tgw_br_prod_ew1_a.id
}

output "snet_tgw_b_id" {
  description = "TGW subnet AZ-b ID"
  value       = aws_subnet.snet_tgw_br_prod_ew1_b.id
}

output "tgw_attachment_id" {
  description = "TGW attachment ID - needed in networkservices for route table association and propagation"
  value       = aws_ec2_transit_gateway_vpc_attachment.tgw_att_br_prod_ew1.id
}

output "ec2_test_instance_id" {
  description = "Test EC2 instance ID - use this in Session Manager to start a session"
  value       = aws_instance.ec2_test_br_prod_ew1.id
}

output "ec2_test_private_ip" {
  description = "Test EC2 private IP"
  value       = aws_instance.ec2_test_br_prod_ew1.private_ip
}
