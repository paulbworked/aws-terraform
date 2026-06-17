# ─────────────────────────────────────────────────────────────────────────────
# S3 bucket for network firewall logging
# Stores Network Firewall alert and flow logs, and VPC Flow Logs.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "s3_network_logs" {
  bucket = "pab-ops-prod-s3-network-logs"

  tags = merge(local.tags, {
    Name = "pab-ops-prod-s3-network-logs"
  })
}

resource "aws_s3_bucket_versioning" "s3_network_logs" {
  bucket = aws_s3_bucket.s3_network_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_network_logs" {
  bucket = aws_s3_bucket.s3_network_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_network_logs" {
  bucket = aws_s3_bucket.s3_network_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_network_logs" {
  bucket = aws_s3_bucket.s3_network_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "s3_network_logs" {
  bucket = aws_s3_bucket.s3_network_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.s3_network_logs.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"    = "bucket-owner-full-control"
            "aws:SourceOrgID" = "o-xxxxxxxxxxxx"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.s3_network_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceOrgID" = "o-xxxxxxxxxxxx"
          }
        }
      },
      {
        Sid    = "AWSNetworkFirewallLogsWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.s3_network_logs.arn}/network-firewall/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"    = "bucket-owner-full-control"
            "aws:SourceOrgID" = "o-xxxxxxxxxxxx"
          }
        }
      },
      {
        Sid    = "AWSNetworkFirewallLogsAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.s3_network_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceOrgID" = "o-xxxxxxxxxxxx"
          }
        }
      }
    ]
  })
}
