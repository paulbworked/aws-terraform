# ─────────────────────────────────────────────────────────────────────────────
# Network firewall rule groups
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# Stateful Rule Group: Azure Bound Allow
# Explicitly permits traffic to and from Azure (0.0.0.0/0) over the S2S tunnel.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_networkfirewall_rule_group" "rg_azure_allow_prod_ew1" {
  capacity = 100
  name     = "rg-azure-allow-prod-ew1"
  type     = "STATEFUL"

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }

    rule_variables {
      ip_sets {
        key = "AWS_VPCS"
        ip_set {
          definition = [
            "0.0.0.0/0",
            "0.0.0.0/0",
            "0.0.0.0/0",
            "0.0.0.0/0",
          ]
        }
      }
    }

    rules_source {

      # Traffic from AWS VPCs to Azure
      stateful_rule {
        action = "PASS"
        header {
          destination      = "0.0.0.0/0"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "IP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["1"]
        }
      }

      # Traffic from Azure to AWS VPCs
      stateful_rule {
        action = "PASS"
        header {
          destination      = "$AWS_VPCS"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "IP"
          source           = "0.0.0.0/0"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["6"]
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = "rg-azure-allow-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Stateful Rule Group: Egress Allow
# Permits outbound HTTP, HTTPS and DNS from all AWS VPC CIDRs to any destination.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_networkfirewall_rule_group" "rg_egress_allow_prod_ew1" {
  capacity = 100
  name     = "rg-egress-allow-prod-ew1"
  type     = "STATEFUL"

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "443"
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "0.0.0.0/0"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["2"]
        }
      }

      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "80"
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "0.0.0.0/0"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["3"]
        }
      }

      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "53"
          direction        = "FORWARD"
          protocol         = "UDP"
          source           = "0.0.0.0/0"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["4"]
        }
      }

      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "53"
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "0.0.0.0/0"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["5"]
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = "rg-egress-allow-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Network firewall policy
# Associates rule groups with the firewall.
# Default action: drop all stateful traffic not explicitly permitted.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_networkfirewall_firewall_policy" "nfw_policy_prod_ew1" {
  name = "nfw-policy-pab-prod-ew1"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_default_actions = ["aws:drop_established"]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.rg_azure_allow_prod_ew1.arn
    }

    stateful_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.rg_egress_allow_prod_ew1.arn
    }
  }

  tags = merge(local.tags, {
    Name = "nfw-policy-pab-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Network firewall
# Deployed across both AZs using the dedicated firewall subnets.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_networkfirewall_firewall" "nfw_prod_ew1" {
  name                = "nfw-pab-prod-ew1"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.nfw_policy_prod_ew1.arn
  vpc_id              = aws_vpc.vpc_hub_prod_ew1.id

  subnet_mapping {
    subnet_id = aws_subnet.snet_firewall_prod_ew1_a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.snet_firewall_prod_ew1_b.id
  }

  tags = merge(local.tags, {
    Name = "nfw-pab-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Network firewall logging
# Alert logs: traffic matching drop rules.
# Flow logs: all accepted traffic flows.
# Both delivered to network logs S3 bucket.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_networkfirewall_logging_configuration" "nfw_logging_prod_ew1" {
  firewall_arn = aws_networkfirewall_firewall.nfw_prod_ew1.arn

  logging_configuration {
    log_destination_config {
      log_destination_type = "S3"
      log_type             = "ALERT"
      log_destination = {
        bucketName = aws_s3_bucket.s3_network_logs.id
        prefix     = "network-firewall/alert"
      }
    }

    log_destination_config {
      log_destination_type = "S3"
      log_type             = "FLOW"
      log_destination = {
        bucketName = aws_s3_bucket.s3_network_logs.id
        prefix     = "network-firewall/flow"
      }
    }
  }
}
