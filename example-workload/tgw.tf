# ─────────────────────────────────────────────────────────────────────────────
# Transit Gateway attachment — Bedrock Prod VPC
# Attaches the Bedrock Prod VPC to the Transit Gateway.
# Two AZs for resilience.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_att_br_prod_ew1" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.vpc_br_prod_ew1.id
  subnet_ids = [
    aws_subnet.snet_tgw_br_prod_ew1_a.id,
    aws_subnet.snet_tgw_br_prod_ew1_b.id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.tags, {
    Name = "tgw-att-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Route table — Bedrock Prod VPC
# Single route table for all subnets.
# Default route points to TGW — all traffic exits via Hub VPC.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "rt_br_prod_ew1" {
  vpc_id = aws_vpc.vpc_br_prod_ew1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = merge(local.tags, {
    Name = "rt-br-prod-ew1"
  })
}

resource "aws_route_table_association" "rta_app_br_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_app_br_prod_ew1_a.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_data_br_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_data_br_prod_ew1_a.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_pep_br_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_pep_br_prod_ew1_a.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_ec2_br_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_ec2_br_prod_ew1_a.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_tgw_br_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_tgw_br_prod_ew1_a.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_app_br_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_app_br_prod_ew1_b.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_data_br_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_data_br_prod_ew1_b.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_pep_br_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_pep_br_prod_ew1_b.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_ec2_br_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_ec2_br_prod_ew1_b.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}

resource "aws_route_table_association" "rta_tgw_br_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_tgw_br_prod_ew1_b.id
  route_table_id = aws_route_table.rt_br_prod_ew1.id
}
