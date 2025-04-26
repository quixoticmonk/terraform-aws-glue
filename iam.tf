locals {
  create_iam_role = var.create && var.create_iam_role
}

# IAM role for Glue
resource "aws_iam_role" "glue" {
  count = local.create_iam_role ? 1 : 0

  name = var.iam_role_name != null ? "${var.prefix}${var.iam_role_name}" : "${var.prefix}glue-service-role"
  
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
  
  tags = var.tags
}

# Attach AWS managed policy for Glue service role
resource "aws_iam_role_policy_attachment" "glue_service" {
  count = local.create_iam_role ? 1 : 0

  role       = aws_iam_role.glue[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Add S3 bucket access policy for Glue jobs
data "aws_iam_policy_document" "glue_s3_access" {
  count = var.create && var.create_iam_role && var.create_job && local.use_s3_bucket ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "glue_s3_access" {
  count = var.create && var.create_iam_role && var.create_job && local.use_s3_bucket ? 1 : 0

  name        = "${var.prefix}glue-s3-access-policy"
  description = "Policy for Glue job to access S3 bucket for scripts and data"
  policy      = data.aws_iam_policy_document.glue_s3_access[0].json
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  count = var.create && var.create_iam_role && var.create_job && local.use_s3_bucket ? 1 : 0

  role       = aws_iam_role.glue[0].name
  policy_arn = aws_iam_policy.glue_s3_access[0].arn
}
