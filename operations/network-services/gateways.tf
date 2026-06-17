# ─────────────────────────────────────────────────────────────────────────────
# Internet Gateway
# Attached to the Hub VPC to support the NAT Gateways.
# No resources connect directly to the IGW — all egress goes via NAT.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_internet_gateway" "igw_prod_ew1" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  tags = merge(local.tags, {
    Name = "igw-pab-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Elastic IPs for NAT Gateways
# One per AZ — NAT Gateways require a static public IP.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_eip" "eip_nat_prod_ew1_a" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "eip-nat-prod-ew1-a"
  })
}

resource "aws_eip" "eip_nat_prod_ew1_b" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "eip-nat-prod-ew1-b"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# NAT Gateways
# One per AZ for resilience. Placed in the snet-nat subnets.
# All internet egress from workload VPCs routes here via TGW and firewall.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_nat_gateway" "nat_prod_ew1_a" {
  allocation_id = aws_eip.eip_nat_prod_ew1_a.id
  subnet_id     = aws_subnet.snet_nat_prod_ew1_a.id

  tags = merge(local.tags, {
    Name = "nat-pab-prod-ew1-a"
  })

  depends_on = [aws_internet_gateway.igw_prod_ew1]
}

resource "aws_nat_gateway" "nat_prod_ew1_b" {
  allocation_id = aws_eip.eip_nat_prod_ew1_b.id
  subnet_id     = aws_subnet.snet_nat_prod_ew1_b.id

  tags = merge(local.tags, {
    Name = "nat-pab-prod-ew1-b"
  })

  depends_on = [aws_internet_gateway.igw_prod_ew1]
}
