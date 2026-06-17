# aws-workload-prod

Terraform code for the AWS production workload VPC — a fully private, dual-AZ VPC that attaches to the Transit Gateway in the Network Services account and provides the network foundation for running AWS application workloads privately within the organisation's AWS estate.

## Overview

This workspace deploys the Workload Prod VPC and everything required to connect it to the shared network hub. It is a consumer of the Network Services workspace — referencing TGW IDs, route table IDs and RAM-shared resolver rules as inputs. It extends the standard workload VPC pattern with additional VPC endpoints required for the specific services this workload needs.

## Files

| File | Description |
|------|-------------|
| `vpc.tf` | Workload Prod VPC, public access block and all subnets across two AZs (app, data, PEP, EC2, TGW per AZ) |
| `tgw.tf` | Transit Gateway attachment across two AZs, route table and associations for all subnets — default route via TGW |
| `dns.tf` | Route 53 Resolver rule associations — attaches RAM-shared forwarding rules from Network Services to this VPC |
| `endpoints.tf` | VPC interface endpoints — Secrets Manager, SSM, SSM Messages, EC2 Messages, ECR API, ECR DKR, CloudWatch Logs, S3 Gateway and optional service-specific endpoints |
| `ec2.tf` | IAM role, instance profile, security group and EC2 test instance for connectivity testing via Session Manager |
| `flowlogs.tf` | VPC Flow Logs delivered to the shared network logs S3 bucket in Network Services |
| `locals.tf` | Tags local |
| `variables.tf` | Input variables — region, TGW ID, route table IDs, RAM share ARN and network logs bucket ARN from Network Services |
| `outputs.tf` | Outputs for VPC ID, all subnet IDs per AZ, TGW attachment ID and EC2 test instance details |
| `provider.tf` | AWS provider configuration |

## Architecture Decisions

### Dual AZ

Unlike the Operations VPC (single AZ), the Workload VPC spans two AZs (eu-west-1a and eu-west-1b). This provides resilience for production workloads — if one AZ becomes unavailable, workloads can continue in the other. All subnets (app, data, PEP, EC2, TGW) are mirrored across both AZs.

### No Internet Gateway

`aws_vpc_block_public_access_options` is set to `block-bidirectional` — no internet gateway, no public IPs. All traffic exits via the Transit Gateway to the Hub VPC where the Network Firewall controls egress.

### Subnet Design

| Subnet | AZs | Purpose |
|--------|-----|---------|
| `snet-app` | a, b | Application workloads |
| `snet-data` | a, b | Data services |
| `snet-pep` | a, b | VPC interface endpoints |
| `snet-ec2` | a, b | EC2 instances |
| `snet-tgw` | a, b | Transit Gateway attachment ENIs |

All subnets use a single route table with a default route via the Transit Gateway.

### VPC Endpoints

A comprehensive set of interface endpoints ensures all AWS service calls stay within the private network without traversing the internet:

| Endpoint | Type | Purpose |
|----------|------|---------|
| `secretsmanager` | Interface | Retrieve secrets without internet |
| `ssm` | Interface | SSM Session Manager |
| `ssmmessages` | Interface | SSM Session Manager |
| `ec2messages` | Interface | SSM Session Manager |
| `ecr.api` | Interface | Pull images from ECR |
| `ecr.dkr` | Interface | Pull image layers from ECR |
| `logs` | Interface | CloudWatch Logs |
| `s3` | Gateway | S3 access via route table — no security group needed |

The S3 endpoint is a Gateway type rather than Interface — it attaches to the route table directly and is cost-free, unlike interface endpoints which have an hourly charge.

### DNS Forwarding via RAM

Route 53 Resolver forwarding rules shared from Network Services are associated with this VPC, enabling seamless DNS resolution for all Azure private DNS zones over the S2S tunnel without any per-VPC DNS configuration.

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
- `vpc.tf` — replace `0.0.0.0/0` CIDR placeholders with your actual VPC and subnet address ranges

## Author

Paul Boardman — [linkedin.com/in/paulboardman76](https://linkedin.com/in/paulboardman76)

