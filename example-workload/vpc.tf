# ─────────────────────────────────────────────────────────────────────────────
# Bedrock Prod VPC
# Workload VPC for the Bedrock-ProdTS account.
# Two AZs — eu-west-1a and eu-west-1b for resilience.
# Connects to the Hub VPC via Transit Gateway attachment.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "vpc_br_prod_ew1" {
  cidr_block           = "0.0.0.0/0"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "vpc-br-prod-ew1"
  })
}

resource "aws_vpc_block_public_access_options" "br_prod_ew1" {
  internet_gateway_block_mode = "block-bidirectional"
}

# ─────────────────────────────────────────────────────────────────────────────
# Subnets — eu-west-1a
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_subnet" "snet_app_br_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-app-br-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_data_br_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-data-br-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_pep_br_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-pep-br-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_ec2_br_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-ec2-br-prod-ew1-a"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Subnets — eu-west-1b
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_subnet" "snet_app_br_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-app-br-prod-ew1-b"
  })
}

resource "aws_subnet" "snet_data_br_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-data-br-prod-ew1-b"
  })
}

resource "aws_subnet" "snet_pep_br_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-pep-br-prod-ew1-b"
  })
}

resource "aws_subnet" "snet_ec2_br_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-ec2-br-prod-ew1-b"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW subnets — one per AZ
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_subnet" "snet_tgw_br_prod_ew1_a" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-tgw-br-prod-ew1-a"
  })
}

resource "aws_subnet" "snet_tgw_br_prod_ew1_b" {
  vpc_id                  = aws_vpc.vpc_br_prod_ew1.id
  cidr_block              = "0.0.0.0/0"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "snet-tgw-br-prod-ew1-b"
  })
}
