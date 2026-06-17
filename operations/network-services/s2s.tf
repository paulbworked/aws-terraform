# ─────────────────────────────────────────────────────────────────────────────
# Site-to-Site VPN — Azure VWAN
# Customer Gateway represents the Azure VWAN VPN Gateway.
# VPN Connection attaches directly to the Transit Gateway.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_customer_gateway" "cgw_azure_prod_ew1" {
  bgp_asn    = var.azure_bgp_asn
  ip_address = var.azure_vpn_gateway_ip
  type       = "ipsec.1"

  tags = merge(local.tags, {
    Name = "cgw-azure-prod-ew1"
  })
}

resource "aws_vpn_connection" "vpn_azure_prod_ew1" {
  transit_gateway_id  = aws_ec2_transit_gateway.tgw_prod_ew1.id
  customer_gateway_id = aws_customer_gateway.cgw_azure_prod_ew1.id
  type                = "ipsec.1"
  enable_acceleration = false

  tunnel1_inside_cidr         = "169.254.21.0/30"
  tunnel1_dpd_timeout_seconds = 45
  tunnel1_dpd_timeout_action  = "restart"

  tunnel1_ike_versions                 = ["ikev2"]
  tunnel1_phase1_encryption_algorithms = ["AES256-GCM-16"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-384"]
  tunnel1_phase1_dh_group_numbers      = [20]
  tunnel1_phase2_encryption_algorithms = ["AES256-GCM-16"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-384"]
  tunnel1_phase2_dh_group_numbers      = [20]
  tunnel1_phase2_lifetime_seconds      = 3600

  tunnel2_inside_cidr         = "169.254.22.0/30"
  tunnel2_dpd_timeout_seconds = 45
  tunnel2_dpd_timeout_action  = "restart"

  tunnel2_ike_versions                 = ["ikev2"]
  tunnel2_phase1_encryption_algorithms = ["AES256-GCM-16"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-384"]
  tunnel2_phase1_dh_group_numbers      = [20]
  tunnel2_phase2_encryption_algorithms = ["AES256-GCM-16"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-384"]
  tunnel2_phase2_dh_group_numbers      = [20]
  tunnel2_phase2_lifetime_seconds      = 3600

  tags = merge(local.tags, {
    Name = "vpn-azure-prod-ew1"
  })
}
