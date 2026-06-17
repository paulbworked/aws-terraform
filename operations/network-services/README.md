# aws-network-services

Terraform code for the AWS network services workspace — the central hub infrastructure that all workload VPCs connect to. Implements a fully private, hub-and-spoke architecture using Transit Gateway, AWS Network Firewall, Route 53 Resolver and a Site-to-Site VPN connection to Azure.

## Overview

This workspace owns the shared network infrastructure for the AWS estate. It is deployed once and all workload VPCs attach to it via the Transit Gateway. All traffic — east-west between workloads, egress to the internet and cross-cloud to Azure — is routed through the Network Firewall for inspection before reaching its destination.

## Files

| File | Description |
|------|-------------|
| `hub.tf` | Transit Gateway, Hub and Spoke route tables, Hub VPC and all Hub VPC subnets (NAT, firewall, TGW, PEP) |
| `hubrt.tf` | Route tables for all Hub VPC subnets — NAT, firewall, TGW and PEP — with associations and per-AZ firewall endpoint routing |
| `firewall.tf` | Network Firewall rule groups (Azure allow, egress allow), firewall policy, firewall deployment and logging configuration |
| `gateways.tf` | Internet Gateway, Elastic IPs and NAT Gateways (one per AZ) for internet egress |
| `dns.tf` | Route 53 Resolver inbound and outbound endpoints, forwarding rules for all Azure private DNS zones, RAM shares for resolver rules and Transit Gateway |
| `s2s.tf` | Customer Gateway and Site-to-Site VPN connection to Azure VWAN with IKEv2, AES256-GCM-16 encryption and BGP |
| `s3.tf` | S3 bucket for network firewall and VPC flow logs — versioned, encrypted, lifecycle policy, bucket policy |
| `flowlogs.tf` | VPC Flow Logs configuration for the Hub VPC |
| `workload-attachments.tf` | TGW route table associations and propagations for all workload VPC attachments and the S2S VPN |
| `local.tf` | Tags local |
| `variables.tf` | Input variables — region, TGW attachment IDs for workload VPCs, Azure VPN gateway IP and BGP configuration |
| `outputs.tf` | Outputs for TGW ID, route table IDs, Hub VPC ID, NAT EIPs, R53 endpoint IPs, RAM share ARN, S3 bucket and S2S VPN tunnel details |
| `provider.tf` | AWS provider configuration |

## Architecture

### Hub and Spoke via Transit Gateway

The Transit Gateway is the central routing hub. Two route tables control traffic flow:

| Route Table | Attached to | Purpose |
|-------------|-------------|---------|
| Spoke | All workload VPC attachments | Routes all traffic to Hub VPC for firewall inspection |
| Hub | Hub VPC attachment | Contains direct routes to all workload VPCs and S2S VPN for post-inspection forwarding |

All workload VPCs have no direct routes to each other — all east-west traffic transits the Hub VPC and firewall.

### Network Firewall — Symmetric Per-AZ Routing

The Network Firewall is deployed across two AZs. Per-AZ symmetric routing is enforced via the TGW subnet route tables — each AZ's TGW subnet routes to that AZ's firewall endpoint specifically. This prevents asymmetric routing where traffic enters via one AZ's firewall and exits via another, which would cause the firewall to drop the connection.

Terraform extracts the per-AZ firewall endpoint IDs using:
```hcl
tolist(aws_networkfirewall_firewall.nfw_prod_ew1.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
```
The `[0]` and `[1]` index maps to AZ-a and AZ-b respectively.

### Firewall Policy

Two stateful rule groups in strict order:

| Priority | Rule Group | Purpose |
|----------|------------|---------|
| 10 | Azure Allow | Permits traffic to and from Azure CIDRs over the S2S tunnel in both directions |
| 20 | Egress Allow | Permits outbound HTTP (80), HTTPS (443) and DNS (53) from all AWS VPC CIDRs |

Default action: `aws:drop_established` — all traffic not explicitly permitted is dropped.

### Site-to-Site VPN to Azure

Two IPsec tunnels connect AWS to Azure VWAN using IKEv2 with AES256-GCM-16 encryption and SHA2-384 integrity. BGP is enabled for dynamic route exchange. The VPN attaches directly to the Transit Gateway, so Azure traffic follows the same inspection path as all other traffic.

### DNS Resolution — Cross-Cloud

Route 53 Resolver enables seamless DNS resolution across AWS and Azure:

- **Inbound endpoint** — accepts DNS queries from Azure arriving over the S2S tunnel. The assigned private IPs are configured as forwarding targets on the Azure DNS server
- **Outbound endpoint** — forwards DNS queries for Azure private DNS zones to the Azure DNS server over the S2S tunnel
- **Forwarding rules** — one rule per Azure private DNS zone, shared to all accounts in the AWS Organisation via RAM so workload VPCs automatically resolve Azure private endpoints

### S3 Logging

A dedicated S3 bucket receives Network Firewall alert and flow logs, and VPC Flow Logs. The bucket is encrypted (AES256), versioned, has all public access blocked and a 90-day lifecycle expiry policy.

## Workload VPC Onboarding

To attach a new workload VPC to the network:

1. Deploy the workload VPC in its own workspace with a TGW attachment referencing the TGW ID output from this workspace
2. Add the TGW attachment ID as a variable in `variables.tf`
3. Add association and propagation resources in `workload-attachments.tf`
4. Add the workload VPC CIDR to the firewall rule groups if east-west traffic rules are required

## What Needs Updating for Your Environment

The following values are placeholders and must be replaced with real values:

- `variables.tf` — TGW attachment IDs, Azure VPN gateway IP and BGP peer IP
- `dns.tf` — AWS account ID, AWS organisation ID and the `pabcompany.internal` DNS zone name
- `s3.tf` — AWS organisation ID in the bucket policy
- `firewall.tf` — VPC CIDR ranges in the `AWS_VPCS` IP set

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

