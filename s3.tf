locals {
  create_s3_bucket = var.create && var.create_job && var.create_s3_bucket
  use_s3_bucket    = var.create && var.create_job
  
  # Determine which bucket to use
  s3_bucket_name = local.create_s3_bucket ? (
    var.s3_bucket_name != null ? var.s3_bucket_name : "${var.prefix}glue-scripts-${random_string.random[0].result}"
  ) : var.existing_s3_bucket_name
  
  # Determine the S3 key for the script
  script_filename = var.job_script_local_path != null ? basename(var.job_script_local_path) : null
  script_s3_key   = var.job_script_s3_key != null ? var.job_script_s3_key : (
    var.job_script_local_path != null ? "scripts/${local.script_filename}" : null
  )
  
  # Determine the full S3 path for the script
  script_s3_location = local.use_s3_bucket && var.job_script_local_path != null ? (
    "s3://${local.s3_bucket_name}/${local.script_s3_key}"
  ) : var.job_command_script_location
  
  # Add Python dependencies to job arguments if provided
  python_dependencies_s3_path = local.use_s3_bucket && var.python_dependencies_local_path != null ? (
    "s3://${local.s3_bucket_name}/${var.python_dependencies_s3_key}"
  ) : null
}

# Generate a random string for S3 bucket name if needed
resource "random_string" "random" {
  count   = local.create_s3_bucket && var.s3_bucket_name == null ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

# Create S3 bucket for Glue scripts if requested
resource "aws_s3_bucket" "glue_scripts" {
  count = local.create_s3_bucket ? 1 : 0
  
  bucket        = local.s3_bucket_name
  force_destroy = var.s3_bucket_force_destroy
  
  tags = merge(
    var.tags,
    var.s3_bucket_tags,
    {
      Name = local.s3_bucket_name
    }
  )
}

# Set bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "glue_scripts" {
  count = local.create_s3_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.glue_scripts[0].id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configure server-side encryption for S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "glue_scripts" {
  count = local.create_s3_bucket && var.enable_s3_encryption ? 1 : 0
  
  bucket = aws_s3_bucket.glue_scripts[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.s3_kms_key_arn
    }
  }
}

# Upload the Glue script to S3
resource "aws_s3_object" "glue_script" {
  count = local.use_s3_bucket && var.job_script_local_path != null ? 1 : 0
  
  bucket = local.create_s3_bucket ? aws_s3_bucket.glue_scripts[0].id : local.s3_bucket_name
  key    = local.script_s3_key
  source = var.job_script_local_path
  etag   = filemd5(var.job_script_local_path)
  
  tags = var.tags
}

# Upload additional script files to S3
resource "aws_s3_object" "additional_scripts" {
  for_each = local.use_s3_bucket ? var.additional_script_files : {}
  
  bucket = local.create_s3_bucket ? aws_s3_bucket.glue_scripts[0].id : local.s3_bucket_name
  key    = each.key
  source = each.value
  etag   = filemd5(each.value)
  
  tags = var.tags
}

# Upload Python dependencies zip if provided
resource "aws_s3_object" "python_dependencies" {
  count = local.use_s3_bucket && var.python_dependencies_local_path != null ? 1 : 0
  
  bucket = local.create_s3_bucket ? aws_s3_bucket.glue_scripts[0].id : local.s3_bucket_name
  key    = var.python_dependencies_s3_key
  source = var.python_dependencies_local_path
  etag   = filemd5(var.python_dependencies_local_path)
  
  tags = var.tags
}
