# ─────────────────────────────────────────────────────────────────────────────
# VPC Flow Logs — Bedrock Prod VPC
# Captures all traffic flows in and out of the Bedrock Prod VPC.
# Delivered to the shared network logs S3 bucket in Network-Services.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_flow_log" "br_prod_ew1" {
  vpc_id               = aws_vpc.vpc_br_prod_ew1.id
  traffic_type         = "ALL"
  log_destination      = var.network_logs_bucket_arn
  log_destination_type = "s3"

  tags = merge(local.tags, {
    Name = "flowlog-br-prod-ew1"
  })
}
