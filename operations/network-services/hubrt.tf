# ─────────────────────────────────────────────────────────────────────────────
# Route tables — Hub VPC
# Four route table types, each with a specific role in the traffic flow.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# NAT subnet route table
# Internet-bound traffic exits via the IGW.
# Return traffic from internet comes back via IGW, NAT translates it,
# then 10.0.0.0/8 route sends it back through the firewall to TGW.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "rt_nat_prod_ew1_a" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id


  # All traffic arriving from the TGW into the Hub VPC goes to the firewall first, no exceptions
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_prod_ew1.id
  }

  # This is how Terraform extracts the per-AZ firewall endpoint ID from the firewall resource. 
  # The [0] and [1] index is AZ-specific — AZ-a's TGW route table points to the AZ-a firewall endpoint, AZ-b's to AZ-b. 
  # This is what makes the per-AZ symmetric routing work.
  route {
    cidr_block      = "10.0.0.0/8"
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.nfw_prod_ew1.firewall_status[0].sync_states)[1].attachment[0].endpoint_id
  }

  tags = merge(local.tags, {
    Name = "rt-nat-prod-ew1-a"
  })
}

resource "aws_route_table" "rt_nat_prod_ew1_b" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_prod_ew1.id
  }

  # This is how Terraform extracts the per-AZ firewall endpoint ID from the firewall resource. 
  # The [0] and [1] index is AZ-specific — AZ-a's TGW route table points to the AZ-a firewall endpoint, AZ-b's to AZ-b. 
  # This is what makes the per-AZ symmetric routing work.
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.nfw_prod_ew1.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
  }

  tags = merge(local.tags, {
    Name = "rt-nat-prod-ew1-b"
  })
}

resource "aws_route_table_association" "rta_nat_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_nat_prod_ew1_a.id
  route_table_id = aws_route_table.rt_nat_prod_ew1_a.id
}

resource "aws_route_table_association" "rta_nat_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_nat_prod_ew1_b.id
  route_table_id = aws_route_table.rt_nat_prod_ew1_b.id
}

# ─────────────────────────────────────────────────────────────────────────────
# Firewall subnet route table
# Post-inspection traffic is forwarded to its destination.
# Egress: forwards to NAT Gateway after inspection.
# Return/ingress: 10.0.0.0/8 routes back to TGW covering all workload VPCs
# and Azure VPN traffic.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "rt_firewall_prod_ew1_a" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  # All traffic arriving from the TGW into the Hub VPC goes to the firewall first, no exceptions
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_prod_ew1_a.id
  }

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw_prod_ew1.id
  }

  tags = merge(local.tags, {
    Name = "rt-firewall-prod-ew1-a"
  })
}

resource "aws_route_table" "rt_firewall_prod_ew1_b" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  # All traffic arriving from the TGW into the Hub VPC goes to the firewall first, no exceptions
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_prod_ew1_b.id
  }

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw_prod_ew1.id
  }

  tags = merge(local.tags, {
    Name = "rt-firewall-prod-ew1-b"
  })
}

resource "aws_route_table_association" "rta_firewall_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_firewall_prod_ew1_a.id
  route_table_id = aws_route_table.rt_firewall_prod_ew1_a.id
}

resource "aws_route_table_association" "rta_firewall_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_firewall_prod_ew1_b.id
  route_table_id = aws_route_table.rt_firewall_prod_ew1_b.id
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW subnet route table
# Traffic arriving from workload VPCs via TGW is sent to the firewall
# for inspection before being forwarded to its destination.
# Uses the firewall endpoint IDs from the Network Firewall resource.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "rt_tgw_prod_ew1_a" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  # All traffic arriving from the TGW into the Hub VPC goes to the firewall first, no exceptions
  # This is how Terraform extracts the per-AZ firewall endpoint ID from the firewall resource. 
  # The [0] and [1] index is AZ-specific — AZ-a's TGW route table points to the AZ-a firewall endpoint, AZ-b's to AZ-b. 
  # This is what makes the per-AZ symmetric routing work.
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.nfw_prod_ew1.firewall_status[0].sync_states)[1].attachment[0].endpoint_id
  }

  tags = merge(local.tags, {
    Name = "rt-tgw-prod-ew1-a"
  })
}

resource "aws_route_table" "rt_tgw_prod_ew1_b" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  # All traffic arriving from the TGW into the Hub VPC goes to the firewall first, no exceptions
  # This is how Terraform extracts the per-AZ firewall endpoint ID from the firewall resource. 
  # The [0] and [1] index is AZ-specific — AZ-a's TGW route table points to the AZ-a firewall endpoint, AZ-b's to AZ-b. 
  # This is what makes the per-AZ symmetric routing work.
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.nfw_prod_ew1.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
  }

  tags = merge(local.tags, {
    Name = "rt-tgw-prod-ew1-b"
  })
}

resource "aws_route_table_association" "rta_tgw_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_tgw_prod_ew1_a.id
  route_table_id = aws_route_table.rt_tgw_prod_ew1_a.id
}

resource "aws_route_table_association" "rta_tgw_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_tgw_prod_ew1_b.id
  route_table_id = aws_route_table.rt_tgw_prod_ew1_b.id
}

# ─────────────────────────────────────────────────────────────────────────────
# PEP subnet route table
# Private endpoints subnet — routes to TGW for any traffic
# needing to leave the VPC.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "rt_pep_prod_ew1" {
  vpc_id = aws_vpc.vpc_hub_prod_ew1.id

  # All traffic arriving from the TGW into the Hub VPC goes to the firewall first, no exceptions
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw_prod_ew1.id
  }

  tags = merge(local.tags, {
    Name = "rt-pep-prod-ew1"
  })
}

resource "aws_route_table_association" "rta_pep_prod_ew1_a" {
  subnet_id      = aws_subnet.snet_pep_prod_ew1_a.id
  route_table_id = aws_route_table.rt_pep_prod_ew1.id
}

resource "aws_route_table_association" "rta_pep_prod_ew1_b" {
  subnet_id      = aws_subnet.snet_pep_prod_ew1_b.id
  route_table_id = aws_route_table.rt_pep_prod_ew1.id
}

# ─────────────────────────────────────────────────────────────────────────────
# TGW attachment — Hub VPC
# Attaches the Hub VPC to the Transit Gateway.
# Associated with the Hub route table — not the Spoke route table.
# Appliance mode enabled — ensures symmetric routing through firewall.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_att_hub_prod_ew1" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_prod_ew1.id
  vpc_id             = aws_vpc.vpc_hub_prod_ew1.id
  subnet_ids         = [aws_subnet.snet_tgw_prod_ew1_a.id, aws_subnet.snet_tgw_prod_ew1_b.id]

  appliance_mode_support = "enable"

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.tags, {
    Name = "tgw-att-hub-prod-ew1"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "hub_att_hub_rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_att_hub_prod_ew1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_hub_prod_ew1.id
}

# ── TGW Spoke route table — default route to Hub VPC firewall ─────────────────
# This route ensures all workload VPC traffic routes through
# the Hub VPC firewall before reaching its destination.

resource "aws_ec2_transit_gateway_route" "spoke_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_spoke_prod_ew1.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_att_hub_prod_ew1.id
}

