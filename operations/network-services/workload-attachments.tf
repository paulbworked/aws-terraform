# ─────────────────────────────────────────────────────────────────────────────
# TGW route table association and propagation — Operations VPC
# Must run in Network-Services as these are operations against the TGW
# which lives in this account.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_route_table_association" "ops_att_spoke_rt" {
  count = var.tgw_att_ops_prod_ew1_id != "" ? 1 : 0

  transit_gateway_attachment_id  = var.tgw_att_ops_prod_ew1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_spoke_prod_ew1.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "ops_att_hub_rt" {
  count = var.tgw_att_ops_prod_ew1_id != "" ? 1 : 0

  transit_gateway_attachment_id  = var.tgw_att_ops_prod_ew1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_hub_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW route table association and propagation — Bedrock Non-Prod VPC
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_route_table_association" "br_np_att_spoke_rt" {
  count = var.tgw_att_br_np_ew1_id != "" ? 1 : 0

  transit_gateway_attachment_id  = var.tgw_att_br_np_ew1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_spoke_prod_ew1.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "br_np_att_hub_rt" {
  count = var.tgw_att_br_np_ew1_id != "" ? 1 : 0

  transit_gateway_attachment_id  = var.tgw_att_br_np_ew1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_hub_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW route table association and propagation — Bedrock Prod VPC
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_route_table_association" "br_prod_att_spoke_rt" {
  count = var.tgw_att_br_prod_ew1_id != "" ? 1 : 0

  transit_gateway_attachment_id  = var.tgw_att_br_prod_ew1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_spoke_prod_ew1.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "br_prod_att_hub_rt" {
  count = var.tgw_att_br_prod_ew1_id != "" ? 1 : 0

  transit_gateway_attachment_id  = var.tgw_att_br_prod_ew1_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_hub_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW route table association and propagation — S2S VPN (Azure)
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_route_table_association" "vpn_azure_att_spoke_rt" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn_azure_prod_ew1.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_spoke_prod_ew1.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_azure_att_hub_rt" {
  transit_gateway_attachment_id  = aws_vpn_connection.vpn_azure_prod_ew1.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_hub_prod_ew1.id
}
