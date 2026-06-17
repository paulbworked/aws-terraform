# ─────────────────────────────────────────────────────────────────────────────
# Security group for VPC endpoints
# Permits HTTPS inbound from within the VPC — all endpoint traffic uses 443.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "sg_endpoints_ops_prod_ew1" {
  name        = "sgr-endpoints-ops-prod-ew1"
  description = "Permits HTTPS inbound from Operations VPC for interface endpoints"
  vpc_id      = aws_vpc.vpc_ops_prod_ew1.id

  ingress {
    description = "HTTPS from Operations VPC"
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
    Name = "sgr-endpoints-ops-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# SSM endpoints
# Required for SSM Session Manager to connect to EC2 instances.
# Three endpoints are needed — ssm, ssmmessages, and ec2messages.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc_ops_prod_ew1.id
  service_name        = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.snet_pep_prod_ew1.id]
  security_group_ids  = [aws_security_group.sg_endpoints_ops_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ssm-ops-prod-ew1"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.vpc_ops_prod_ew1.id
  service_name        = "com.amazonaws.eu-west-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.snet_pep_prod_ew1.id]
  security_group_ids  = [aws_security_group.sg_endpoints_ops_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ssmmessages-ops-prod-ew1"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.vpc_ops_prod_ew1.id
  service_name        = "com.amazonaws.eu-west-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.snet_pep_prod_ew1.id]
  security_group_ids  = [aws_security_group.sg_endpoints_ops_prod_ew1.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "pep-ec2messages-ops-prod-ew1"
  })
}
