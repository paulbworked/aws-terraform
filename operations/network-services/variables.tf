variable "region_euw1" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "tgw_att_ops_prod_ew1_id" {
  description = "TGW attachment ID for Operations VPC — from terraform-aws-ops-operations outputs"
  type        = string
  default     = "tgw-attach-00000000000000000"
}

variable "tgw_att_br_np_ew1_id" {
  description = "TGW attachment ID for Bedrock Non-Prod VPC — from terraform-aws-bedrock-np outputs"
  type        = string
  default     = "tgw-attach-00000000000000000"
}

variable "tgw_att_br_prod_ew1_id" {
  description = "TGW attachment ID for Bedrock Prod VPC — from terraform-aws-bedrock-prod outputs"
  type        = string
  default     = "tgw-attach-00000000000000000"
}

variable "azure_vpn_gateway_ip" {
  description = "Azure VWAN VPN Gateway public IP"
  type        = string
  default     = "0.0.0.0"
}

variable "azure_bgp_peer_ip" {
  description = "Azure VWAN BGP peering address"
  type        = string
  default     = "0.0.0.0"
}

variable "azure_bgp_asn" {
  description = "Azure VWAN BGP ASN"
  type        = number
  default     = 65515
}
