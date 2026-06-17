# aws-operations

Terraform code for the AWS Operations workload VPC — a private, single-AZ VPC that attaches to the Transit Gateway in the Network Services account and inherits all centrally managed network controls including firewall inspection, DNS forwarding and VPC flow logs.

## Overview

This workspace deploys the Operations VPC and everything required to connect it to the shared network hub. It is a consumer of the Network Services workspace — it references TGW IDs, route table IDs and RAM-shared resolver rules as inputs rather than managing them directly.

## Files

| File | Description |
|------|-------------|
| `vpc.tf` | Operations VPC, public access block and all subnets (app, data, PEP, EC2, TGW) |
| `tgw.tf` | Transit Gateway attachment, route table and associations for all subnets — default route via TGW |
| `dns.tf` | Route 53 Resolver rule associations — attaches RAM-shared forwarding rules from Network Services to this VPC |
| `endpoints.tf` | VPC interface endpoints for SSM, SSM Messages and EC2 Messages — enables Session Manager without internet access |
| `ec2.tf` | IAM role, instance profile, security group and EC2 test instance for connectivity testing via Session Manager |
| `flowlogs.tf` | VPC Flow Logs delivered to the shared network logs S3 bucket in Network Services |
| `local.tf` | Tags local |
| `variables.tf` | Input variables — region, TGW ID, route table IDs, RAM share ARN and network logs bucket ARN from Network Services |
| `outputs.tf` | Outputs for VPC ID, subnet IDs, TGW attachment ID and EC2 test instance details |
| `provider.tf` | AWS provider configuration |

## Architecture Decisions

### Single AZ

The Operations VPC is deployed in a single AZ (eu-west-1a). This is an operations/tooling VPC rather than a production application VPC — resilience requirements are lower and a single AZ reduces cost and complexity.

### No Internet Gateway

`aws_vpc_block_public_access_options` is set to `block-bidirectional` — no internet gateway is attached and no public IPs are assigned. All traffic exits via the Transit Gateway to the Hub VPC, where the Network Firewall controls egress to the internet and the NAT Gateway handles address translation.

### Subnet Design

| Subnet | Purpose |
|--------|---------|
| `snet-app` | Application workloads |
| `snet-data` | Data services |
| `snet-pep` | VPC interface endpoints (SSM, EC2 Messages) |
| `snet-ec2` | EC2 instances |
| `snet-tgw` | Transit Gateway attachment ENIs |

All subnets use a single route table with a default route via the Transit Gateway — no subnet-level internet routes.

### SSM Session Manager — No Bastion Required

Three VPC interface endpoints (ssm, ssmmessages, ec2messages) enable AWS Systems Manager Session Manager to connect to EC2 instances without a bastion host, SSH keys or inbound security group rules. All access is authenticated via IAM and logged in CloudTrail.

### DNS Forwarding via RAM

The Network Services account shares Route 53 Resolver forwarding rules for all Azure private DNS zones via RAM. Associating these rules with this VPC means EC2 instances automatically forward Azure DNS queries over the S2S tunnel to the Azure DNS server — no manual DNS configuration required per VPC.

### Test EC2 Instance

A t3.micro Amazon Linux 2023 instance is deployed for connectivity testing. It has no inbound security group rules and no public IP — access is exclusively via Session Manager. The security group permits ICMP from Azure CIDRs for ping-based connectivity verification across the S2S tunnel.

## Dependencies

This workspace depends on outputs from the **aws-network-services** workspace:

| Variable | Source |
|----------|--------|
| `transit_gateway_id` | `transit_gateway_id` output |
| `tgw_route_table_spoke_id` | `tgw_route_table_spoke_id` output |
| `tgw_route_table_hub_id` | `tgw_route_table_hub_id` output |
| `ram_resolver_rules_share_arn` | `ram_resolver_rules_share_arn` output |
| `network_logs_bucket_arn` | `network_logs_bucket_arn` output |

After deployment, the TGW attachment ID output from this workspace must be added to `workload-attachments.tf` in the aws-network-services workspace to register the route table association and propagation.

## What Needs Updating for Your Environment

- `variables.tf` — replace placeholder TGW IDs, route table IDs, RAM share ARN and S3 bucket ARN with real values from your Network Services workspace outputs
- `dns.tf` — replace placeholder resolver rule IDs with the real IDs from your Network Services Route 53 Resolver rules

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

