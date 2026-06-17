# ─────────────────────────────────────────────────────────────────────────────
# VPC Flow Logs — Hub VPC
# Captures all traffic flows in and out of the Hub VPC.
# Delivered to the network logs S3 bucket.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_flow_log" "hub" {
  vpc_id               = aws_vpc.vpc_hub_prod_ew1.id
  traffic_type         = "ALL"
  log_destination      = aws_s3_bucket.s3_network_logs.arn
  log_destination_type = "s3"

  tags = merge(local.tags, {
    Name = "flowlog-hub-prod-ew1"
  })
}
