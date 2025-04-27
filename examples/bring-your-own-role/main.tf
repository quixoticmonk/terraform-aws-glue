provider "aws" {
  region = local.region
}

provider "awscc" {
  region = local.region
}

locals {
  region = "us-west-2"
  name   = "glue-byoiam"

  tags = {
    Name       = local.name
    Example    = "bring-your-own-role"
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-glue"
  }
}

################################################################################
# External IAM Role
################################################################################

resource "aws_iam_role" "external" {
  name = "external-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.external.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

################################################################################
# Glue Module - Using External IAM Role
################################################################################

module "glue" {
  source = "../.."

  # Use external IAM role
  create_iam_role = false
  iam_role_arn    = aws_iam_role.external.arn

  # Catalog Database
  create_catalog_database = true
  catalog_database_name   = "byoiam_database"

  # Crawler
  create_crawler = true
  crawler_name   = "byoiam-crawler"
  crawler_s3_targets = [
    {
      path = "s3://example-bucket/byoiam-path"
    }
  ]

  # Job
  create_job = true
  job_name   = "byoiam-job"
  job_command_script_location = "s3://example-bucket/scripts/byoiam-job.py"

  tags = local.tags
}
