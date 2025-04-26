locals {
  create_security_configuration = var.create && (var.enable_job_bookmarks_encryption || var.enable_cloudwatch_encryption)
  security_configuration_name = "${var.prefix}glue-security-config"
}

resource "aws_glue_security_configuration" "encryption" {
  count = local.create_security_configuration ? 1 : 0

  name = local.security_configuration_name

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = var.enable_cloudwatch_encryption ? "SSE-KMS" : "DISABLED"
      kms_key_arn                = var.enable_cloudwatch_encryption ? var.cloudwatch_encryption_kms_key_arn : null
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = var.enable_job_bookmarks_encryption ? "CSE-KMS" : "DISABLED"
      kms_key_arn                   = var.enable_job_bookmarks_encryption ? var.job_bookmarks_encryption_kms_key_arn : null
    }

    s3_encryption {
      s3_encryption_mode = var.enable_s3_encryption ? (var.s3_kms_key_arn != null ? "SSE-KMS" : "SSE-S3") : "DISABLED"
      kms_key_arn        = var.enable_s3_encryption && var.s3_kms_key_arn != null ? var.s3_kms_key_arn : null
    }
  }
}
