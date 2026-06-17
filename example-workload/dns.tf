# ─────────────────────────────────────────────────────────────────────────────
# R53 Resolver rule association
# Associates the forwarding rules shared from the Network-Services account
# via RAM with this VPC. Once associated, EC2 instances in this VPC
# automatically forward Azure DNS zone queries to vmdnsne and vmdnswe.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route53_resolver_rule_association" "br_prod_ew1" {
  for_each = toset([
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
    "rslvr-rr-00000000000000000",
  ])

  resolver_rule_id = each.value
  vpc_id           = aws_vpc.vpc_br_prod_ew1.id
}
