# ─────────────────────────────────────────────────────────────────────────────
# Security group for Route 53 Resolver endpoints
# Permits DNS queries inbound from Azure over the S2S tunnel.
# Applied to both inbound and outbound endpoints.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "sg_r53_resolver_prod_ew1" {
  name        = "sgr-r53-resolver-prod-ew1"
  description = "Permits DNS queries inbound from Azure over S2S tunnel"
  vpc_id      = aws_vpc.vpc_hub_prod_ew1.id

  ingress {
    description = "DNS UDP from private ranges"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/8"]
  }

  ingress {
    description = "DNS TCP from private ranges"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/8"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "sg-r53-resolver-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Route 53 Resolver — inbound endpoint
# Accepts DNS queries arriving from Azure over the S2S VPN tunnel.
# AWS assigns two private IPs (one per AZ) from snet-pep.
# These IPs are configured as the forwarding target on Azure vmdnsne.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route53_resolver_endpoint" "r53_inbound_prod_ew1" {
  name      = "r53-inbound-prod-ew1"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.sg_r53_resolver_prod_ew1.id]

  ip_address {
    subnet_id = aws_subnet.snet_pep_prod_ew1_a.id
  }

  ip_address {
    subnet_id = aws_subnet.snet_pep_prod_ew1_b.id
  }

  tags = merge(local.tags, {
    Name = "r53-inbound-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Route 53 Resolver — outbound endpoint
# Forwards DNS queries for Azure private DNS zones to vmdnsne (0.0.0.0).
# Queries travel over the S2S tunnel to Azure for resolution.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route53_resolver_endpoint" "r53_outbound_prod_ew1" {
  name      = "r53-outbound-prod-ew1"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.sg_r53_resolver_prod_ew1.id]

  ip_address {
    subnet_id = aws_subnet.snet_pep_prod_ew1_a.id
  }

  ip_address {
    subnet_id = aws_subnet.snet_pep_prod_ew1_b.id
  }

  tags = merge(local.tags, {
    Name = "r53-outbound-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Route 53 Resolver forwarding rules
# One rule per Azure private DNS zone.
# Each rule sends matching queries to vmdnsne via the outbound endpoint.
# Add zones to the local list as Azure private endpoints are added.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  azure_dns_zones = [
    "azurecr.io",
    "azurewebsites.net",
    "blob.core.windows.net",
    "database.windows.net",
    "file.core.windows.net",
    "ne.backup.windowsazure.com",
    "northeurope.azmk8s.io",
    "postgres.database.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.northeurope.azmk8s.io",
    "privatelink.westeurope.azmk8s.io",
    "queue.core.windows.net",
    "servicebus.windows.net",
    "pabcompany.internal",
    "vaultcore.azure.net",
    "westeurope.azmk8s.io",
  ]
}

resource "aws_route53_resolver_rule" "azure_zones" {
  for_each = toset(local.azure_dns_zones)

  domain_name          = each.value
  name                 = replace(each.value, ".", "-")
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.r53_outbound_prod_ew1.id

  target_ip {
    ip   = "0.0.0.0"
    port = 53
  }

  target_ip {
    ip   = "0.0.0.0"
    port = 53
  }

  tags = merge(local.tags, {
    Name = "r53-rule-${replace(each.value, ".", "-")}"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# RAM — share resolver rules to workload accounts
# Shares the R53 forwarding rules to the entire AWS Organisation so EC2
# instances in all workload VPCs automatically forward Azure DNS queries
# correctly. New accounts inherit access automatically.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ram_resource_share" "r53_rules_prod_ew1" {
  name                      = "ram-r53-rules-prod-ew1"
  allow_external_principals = false

  tags = merge(local.tags, {
    Name = "ram-r53-rules-prod-ew1"
  })
}

resource "aws_ram_resource_association" "azure_zones" {
  for_each = aws_route53_resolver_rule.azure_zones

  resource_arn       = each.value.arn
  resource_share_arn = aws_ram_resource_share.r53_rules_prod_ew1.arn
}

resource "aws_ram_principal_association" "org" {
  principal          = "arn:aws:organizations::000000000000:organization/o-xxxxxxxxxxxx"
  resource_share_arn = aws_ram_resource_share.r53_rules_prod_ew1.arn
}

# ─────────────────────────────────────────────────────────────────────────────
# RAM — share Transit Gateway to the organisation
# Workload accounts need to see the TGW to create attachments.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ram_resource_share" "tgw_prod_ew1" {
  name                      = "ram-tgw-prod-ew1"
  allow_external_principals = false

  tags = merge(local.tags, {
    Name = "ram-tgw-prod-ew1"
  })
}

resource "aws_ram_resource_association" "tgw_prod_ew1" {
  resource_arn       = aws_ec2_transit_gateway.tgw_prod_ew1.arn
  resource_share_arn = aws_ram_resource_share.tgw_prod_ew1.arn
}

resource "aws_ram_principal_association" "tgw_org" {
  principal          = "arn:aws:organizations::000000000000:organization/o-xxxxxxxxxxxx"
  resource_share_arn = aws_ram_resource_share.tgw_prod_ew1.arn
}
