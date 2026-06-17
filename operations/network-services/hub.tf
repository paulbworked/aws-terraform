# ─────────────────────────────────────────────────────────────────────────────
# TRANSIT GATEWAY
# Central hub for all VPC attachments and the S2S VPN connection.
# Two route tables enforce all traffic through the Network Firewall.
# ─────────────────────────────────────────────────────────────────────────────

# Transit Gateway — hub and spoke for AWS network
resource "aws_ec2_transit_gateway" "tgw_prod_ew1" {
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(local.tags, {
    Name = "tgw-pab-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW Route Table: Spoke
# Attached to all workload VPC attachments.
# Routes all traffic to the Hub VPC for firewall inspection.
# Workload VPCs have no direct routes to each other.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_route_table" "tgw_spoke_prod_ew1" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_prod_ew1.id

  tags = merge(local.tags, {
    Name = "tgw-rt-spoke-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW Route Table: Hub
# Attached to the Hub VPC attachment.
# Contains direct routes to all workload VPCs and the S2S VPN.
# Used for post-inspection forwarding.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_route_table" "tgw_hub_prod_ew1" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_prod_ew1.id

  tags = merge(local.tags, {
    Name = "tgw-rt-hub-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Hub VPC
# Houses the Network Firewall, NAT Gateway, TGW attachment, and DNS resolvers.
# No workloads run here — infrastructure only.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "vpc_hub_prod_ew1" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "vpc-hub-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Subnets of vpc_hub_prod_ew1
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_subnet" "snet_nat_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.0/27"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-nat-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_nat_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.32/27"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-nat-prod-ew1-b"
  })
}

resource "aws_subnet" "snet_firewall_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.64/28"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-firewall-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_firewall_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.80/28"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-firewall-prod-ew1-b"
  })
}

resource "aws_subnet" "snet_tgw_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.96/28"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-tgw-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_tgw_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.112/28"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-tgw-prod-ew1-b"
  })
}

resource "aws_subnet" "snet_pep_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.128/26"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-pep-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_pep_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_hub_prod_ew1.id
  cidr_block              = "10.50.0.192/26"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-pep-prod-ew1-b"
  })
}

