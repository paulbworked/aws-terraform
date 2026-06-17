# ─────────────────────────────────────────────────────────────────────────────
# Transit Gateway
# ─────────────────────────────────────────────────────────────────────────────

output "transit_gateway_id" {
  description = "TGW ID — needed in all workload VPC workspaces for TGW attachments"
  value       = aws_ec2_transit_gateway.tgw_prod_ew1.id
}

output "tgw_route_table_spoke_id" {
  description = "Spoke route table ID — workload VPC attachments associate with this"
  value       = aws_ec2_transit_gateway_route_table.tgw_spoke_prod_ew1.id
}

output "tgw_route_table_hub_id" {
  description = "Hub route table ID — workload VPC attachments propagate routes to this"
  value       = aws_ec2_transit_gateway_route_table.tgw_hub_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# Hub VPC
# ─────────────────────────────────────────────────────────────────────────────

output "hub_vpc_id" {
  description = "Hub VPC ID"
  value       = aws_vpc.vpc_hub_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# NAT Gateways
# ─────────────────────────────────────────────────────────────────────────────

output "nat_gateway_a_eip" {
  description = "Elastic IP of NAT Gateway AZ-a — your outbound public IP in eu-west-1a"
  value       = aws_eip.eip_nat_prod_ew1_a.public_ip
}

output "nat_gateway_b_eip" {
  description = "Elastic IP of NAT Gateway AZ-b — your outbound public IP in eu-west-1b"
  value       = aws_eip.eip_nat_prod_ew1_b.public_ip
}

# ─────────────────────────────────────────────────────────────────────────────
# Route 53 Resolver
# ─────────────────────────────────────────────────────────────────────────────

output "r53_inbound_endpoint_ips" {
  description = "Private IPs of the R53 inbound endpoint ENIs — configure these as the forwarding target on Azure vmdnsne and vmdnswe"
  value       = aws_route53_resolver_endpoint.r53_inbound_prod_ew1.ip_address[*].ip
}

output "r53_outbound_endpoint_id" {
  description = "R53 outbound endpoint ID — for reference"
  value       = aws_route53_resolver_endpoint.r53_outbound_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# RAM
# ─────────────────────────────────────────────────────────────────────────────

output "ram_resolver_rules_share_arn" {
  description = "RAM share ARN for R53 resolver rules — needed in workload VPC workspaces for rule association"
  value       = aws_ram_resource_share.r53_rules_prod_ew1.arn
}

# ─────────────────────────────────────────────────────────────────────────────
# S3
# ─────────────────────────────────────────────────────────────────────────────

output "network_logs_bucket_name" {
  description = "Network logs S3 bucket name"
  value       = aws_s3_bucket.s3_network_logs.id
}

output "network_logs_bucket_arn" {
  description = "Network logs S3 bucket ARN — for VPC flow log configuration in workload workspaces"
  value       = aws_s3_bucket.s3_network_logs.arn
}

# ─────────────────────────────────────────────────────────────────────────────
# S2S
# ─────────────────────────────────────────────────────────────────────────────

output "vpn_tunnel1_address" {
  value = aws_vpn_connection.vpn_azure_prod_ew1.tunnel1_address
}

output "vpn_tunnel2_address" {
  value = aws_vpn_connection.vpn_azure_prod_ew1.tunnel2_address
}

output "vpn_tunnel1_cgw_inside_address" {
  value = aws_vpn_connection.vpn_azure_prod_ew1.tunnel1_cgw_inside_address
}

output "vpn_tunnel2_cgw_inside_address" {
  value = aws_vpn_connection.vpn_azure_prod_ew1.tunnel2_cgw_inside_address
}

output "vpn_tunnel1_preshared_key" {
  description = "Pre-shared key for tunnel 1 — needed when configuring Azure VWAN VPN Site"
  value       = aws_vpn_connection.vpn_azure_prod_ew1.tunnel1_preshared_key
  sensitive   = true
}

output "vpn_tunnel2_preshared_key" {
  description = "Pre-shared key for tunnel 2 — needed when configuring Azure VWAN VPN Site"
  value       = aws_vpn_connection.vpn_azure_prod_ew1.tunnel2_preshared_key
  sensitive   = true
}
