# ─────────────────────────────────────────────────────────────────────────────
# VPC Flow Logs — Operations VPC
# Captures all traffic flows in and out of the Operations VPC.
# Delivered to the shared network logs S3 bucket in Network-Services.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_flow_log" "ops_prod_ew1" {
  vpc_id               = aws_vpc.vpc_ops_prod_ew1.id
  traffic_type         = "ALL"
  log_destination      = var.network_logs_bucket_arn
  log_destination_type = "s3"

  tags = merge(local.tags, {
    Name = "flowlog-ops-prod-ew1"
  })
}
