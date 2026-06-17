# ─────────────────────────────────────────────────────────────────────────────
# IAM role and instance profile for SSM Session Manager
# Allows the EC2 instance to communicate with SSM via the VPC endpoints.
# AmazonSSMManagedInstanceCore grants the minimum permissions needed.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "ec2_ssm_ops_prod_ew1" {
  name = "role-ec2-ssm-ops-prod-ew1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = merge(local.tags, {
    Name = "role-ec2-ssm-ops-prod-ew1"
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_ops_prod_ew1" {
  role       = aws_iam_role.ec2_ssm_ops_prod_ew1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_ops_prod_ew1" {
  name = "profile-ec2-ssm-ops-prod-ew1"
  role = aws_iam_role.ec2_ssm_ops_prod_ew1.name

  tags = merge(local.tags, {
    Name = "profile-ec2-ssm-ops-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Security group for test EC2
# No inbound rules — access is via SSM Session Manager only.
# Outbound allows all — firewall in Hub VPC enforces egress policy.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "sg_ec2_ops_prod_ew1" {
  name   = "sgr-ec2-ops-prod-ew1"
  vpc_id = aws_vpc.vpc_ops_prod_ew1.id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP from Azure"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "sgr-ec2-ops-prod-ew1"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Test EC2 instance
# Amazon Linux 2023 — SSM agent pre-installed.
# Deployed in snet-ec2-prod-ew1, no public IP.
# Access via SSM Session Manager in the AWS console.
# ─────────────────────────────────────────────────────────────────────────────

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ec2_test_ops_prod_ew1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.snet_ec2_prod_ew1.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_ops_prod_ew1.name
  vpc_security_group_ids = [aws_security_group.sg_ec2_ops_prod_ew1.id]

  associate_public_ip_address = false

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.tags, {
    Name = "ec2opspocew1"
  })
}
