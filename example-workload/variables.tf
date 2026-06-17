variable "region_euw1" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "transit_gateway_id" {
  description = "TGW ID from networkservices workspace"
  type        = string
  default     = "tgw-00000000000000000"
}

variable "tgw_route_table_spoke_id" {
  description = "Spoke route table ID from networkservices workspace"
  type        = string
  default     = "tgw-rtb-00000000000000000"
}

variable "tgw_route_table_hub_id" {
  description = "Hub route table ID from networkservices workspace"
  type        = string
  default     = "tgw-rtb-00000000000000000"
}

variable "ram_resolver_rules_share_arn" {
  description = "RAM share ARN for R53 resolver rules from networkservices workspace"
  type        = string
  default     = "arn:aws:ram:eu-west-1:000000000000:resource-share/00000000-0000-0000-0000-000000000000"
}

variable "network_logs_bucket_arn" {
  description = "Network logs S3 bucket ARN from networkservices workspace"
  type        = string
  default     = "arn:aws:s3:::pab-ops-prod-s3-network-logs"
}
