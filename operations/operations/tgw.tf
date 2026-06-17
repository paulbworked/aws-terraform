# ─────────────────────────────────────────────────────────────────────────────
# Transit Gateway attachment — Operations VPC
# Attaches the Operations VPC to the Transit Gateway.
# Associated with the Spoke route table — traffic is forced through
# the Hub VPC firewall before reaching any destination.
# Routes propagate to the Hub route table automatically.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_att_ops_prod_ew1" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.vpc_ops_prod_ew1.id
  subnet_ids         = [aws_subnet.snet_tgw_prod_ew1.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.tags, {
    Name = "tgw-att-ops-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Route table — Operations VPC
# Single route table for all subnets.
# Default route points to TGW — all traffic exits via Hub VPC.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "rt_ops_prod_ew1" {
  vpc_id = aws_vpc.vpc_ops_prod_ew1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = merge(local.tags, {
    Name = "rt-ops-prod-ew1"
  })
}

resource "aws_route_table_association" "rta_app_prod_ew1" {
  subnet_id      = aws_subnet.snet_app_prod_ew1.id
  route_table_id = aws_route_table.rt_ops_prod_ew1.id
}

resource "aws_route_table_association" "rta_data_prod_ew1" {
  subnet_id      = aws_subnet.snet_data_prod_ew1.id
  route_table_id = aws_route_table.rt_ops_prod_ew1.id
}

resource "aws_route_table_association" "rta_pep_prod_ew1" {
  subnet_id      = aws_subnet.snet_pep_prod_ew1.id
  route_table_id = aws_route_table.rt_ops_prod_ew1.id
}

resource "aws_route_table_association" "rta_ec2_prod_ew1" {
  subnet_id      = aws_subnet.snet_ec2_prod_ew1.id
  route_table_id = aws_route_table.rt_ops_prod_ew1.id
}

resource "aws_route_table_association" "rta_tgw_prod_ew1" {
  subnet_id      = aws_subnet.snet_tgw_prod_ew1.id
  route_table_id = aws_route_table.rt_ops_prod_ew1.id
}
