# ----------------------------
# Get Latest Amazon Linux 2023 AMI
# ----------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ----------------------------
# IAM Assume Role Policy for EC2
# ----------------------------
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ----------------------------
# IAM Role for EC2
# ----------------------------
resource "aws_iam_role" "ec2_role" {
  name               = "terraform_ec2_access_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  tags = {
    purpose = "ec2-ssm-access"
  }
}

# ----------------------------
# Attach Multiple Policies
# ----------------------------
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}

# ----------------------------
# Instance Profile
# ----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "terraform_ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "example" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "terraform-ec2-ssm"
  }
}
