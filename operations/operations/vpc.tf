# ─────────────────────────────────────────────────────────────────────────────
# Operations VPC
# Workload VPC for the Operations-Prod account.
# Single AZ — eu-west-1a.
# Connects to the Hub VPC via Transit Gateway attachment.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "vpc_ops_prod_ew1" {
  cidr_block           = "0.0.0.0/0"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "vpc-ops-prod-ew1"
  })
}

resource "aws_vpc_block_public_access_options" "ops_prod_ew1" {
  internet_gateway_block_mode = "block-bidirectional"
}

# ─────────────────────────────────────────────────────────────────────────────
# Subnets
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_subnet" "snet_app_prod_ew1" {
  vpc_id                  = aws_vpc.vpc_ops_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-app-prod-ew1"
  })
}

resource "aws_subnet" "snet_data_prod_ew1" {
  vpc_id                  = aws_vpc.vpc_ops_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-data-prod-ew1"
  })
}

resource "aws_subnet" "snet_pep_prod_ew1" {
  vpc_id                  = aws_vpc.vpc_ops_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-pep-prod-ew1"
  })
}

resource "aws_subnet" "snet_ec2_prod_ew1" {
  vpc_id                  = aws_vpc.vpc_ops_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-ec2-prod-ew1"
  })
}

resource "aws_subnet" "snet_tgw_prod_ew1" {
  vpc_id                  = aws_vpc.vpc_ops_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-tgw-prod-ew1"
  })
}
