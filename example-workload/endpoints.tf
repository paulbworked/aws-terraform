# ─────────────────────────────────────────────────────────────────────────────
# Security group for VPC endpoints
# Permits HTTPS inbound from within the VPC — all endpoint traffic uses 443.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "sg_endpoints_br_prod_ew1" {
  name        = "sgr-endpoints-br-prod-ew1"
  description = "Permits HTTPS inbound from Bedrock Prod VPC for interface endpoints"
  vpc_id      = aws_vpc.vpc_br_prod_ew1.id

  ingress {
    description = "HTTPS from Bedrock Prod VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "sgr-endpoints-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Bedrock endpoints
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.bedrock-runtime"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-bedrock-runtime-br-prod-ew1"
  })
}

resource "aws_vpc_endpoint" "bedrock" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.bedrock"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-bedrock-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Secrets Manager endpoint
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-secretsmanager-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# SSM endpoints
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ssm-br-prod-ew1"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ssmmessages-br-prod-ew1"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ec2messages-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# ECR endpoints
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ecr-api-br-prod-ew1"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ecr-dkr-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# CloudWatch Logs endpoint
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.snet_pep_br_prod_ew1_a.id,
    aws_subnet.snet_pep_br_prod_ew1_b.id
  ]
  security_group_ids  = [aws_security_group.sg_endpoints_br_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-logs-br-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# S3 Gateway endpoint
# Gateway type — attaches to route table, not a subnet.
# No security group needed.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc_br_prod_ew1.id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.rt_br_prod_ew1.id]

  tags = merge(local.tags, {
    Name = "pep-s3-br-prod-ew1"
  })
}
