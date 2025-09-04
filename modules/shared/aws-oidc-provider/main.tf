data "aws_region" "current" {}

# OIDC Identity Provider para Azure DevOps
resource "aws_iam_openid_connect_provider" "azure_devops" {
  url = "https://vstoken.dev.azure.com/${var.azure_devops_organization}"

  client_id_list = [
    "499b84ac-1321-427f-aa17-267ca6975798", # Azure DevOps Service Connection client ID
    "https://app.vssps.visualstudio.com"    # Additional client ID for Azure DevOps
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1", # DigiCert root CA thumbprint
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"  # DigiCert SHA2 High Assurance Server CA
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-azure-devops-oidc-provider"
    }
  )
}

# IAM Role para Azure DevOps pipelines
resource "aws_iam_role" "azure_devops_role" {
  name = "${var.project_name}-azure-devops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.azure_devops.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "vstoken.dev.azure.com/${var.azure_devops_organization}:sub" = "sc://${var.azure_devops_organization}/${var.azure_devops_project}/${var.project_name}-aws-connection"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-azure-devops-role"
    }
  )
}

# Policy para permitir operações de Terraform
resource "aws_iam_policy" "terraform_policy" {
  name        = "${var.project_name}-terraform-policy"
  description = "Policy for Terraform operations via Azure DevOps"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # EC2 permissions
          "ec2:*",

          # ECS permissions
          "ecs:*",

          # ECR permissions
          "ecr:*",

          # EKS permissions
          "eks:*",

          # RDS permissions
          "rds:*",

          # Lambda permissions
          "lambda:*",

          # IAM permissions (limited)
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:PassRole",
          "iam:CreateServiceLinkedRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy",

          # ELB permissions
          "elasticloadbalancing:*",

          # CloudWatch permissions
          "logs:*",
          "cloudwatch:*",

          # S3 permissions for Terraform state
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",

          # DynamoDB permissions for Terraform state locking
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",

          # STS permissions
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-terraform-policy"
    }
  )
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "terraform_policy_attachment" {
  role       = aws_iam_role.azure_devops_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}