locals {
  create_job                    = var.create && var.create_job
  create_security_configuration = var.create && (var.enable_job_bookmarks_encryption || var.enable_cloudwatch_encryption)
  security_configuration_name   = "${var.prefix}glue-security-config"

  # Define Python versions based on Glue version for GlueETL jobs
  glue_etl_python_versions = {
    "3.0" = "3.7"
    "4.0" = "3.10"
    "5.0" = "3.11"
  }

  # For PythonShell jobs, only Python 3.9 is supported
  pythonshell_python_version = "3.9"

  # Determine Python version based on job type and Glue version
  python_version = var.job_type == "pythonshell" ? local.pythonshell_python_version : local.glue_etl_python_versions[var.glue_version]

  # Default arguments based on job type and Glue version
  default_arguments = merge(
    {
      "--job-language"            = var.job_language
      "--enable-glue-datacatalog" = "true"
    },
    # Add ETL-specific arguments only for glueetl job type
    var.job_type == "glueetl" ? {
      "--enable-metrics"                   = "true"
      "--enable-continuous-cloudwatch-log" = "true"
    } : {},
    # Add autoscaling configuration if enabled (only for glueetl jobs)
    var.enable_autoscaling && var.job_type == "glueetl" ? {
      "--enable-auto-scaling" = "true"
    } : {},
    var.job_default_arguments,
    var.job_parameters
  )

  # Update default arguments with Python dependencies if provided
  default_arguments_with_deps = local.python_dependencies_s3_path != null ? merge(
    local.default_arguments,
    {
      "--extra-py-files" = local.python_dependencies_s3_path
    }
  ) : local.default_arguments

  # Job name with optional prefix
  job_name = var.job_name != null ? "${var.prefix}${var.job_name}" : null
}

resource "aws_glue_job" "this" {
  count = local.create_job ? 1 : 0

  name                   = local.job_name
  description            = var.job_description
  role_arn               = var.create_iam_role ? aws_iam_role.glue[0].arn : var.iam_role_arn
  glue_version           = var.job_type == "pythonshell" ? null : var.glue_version
  execution_class        = var.job_type == "pythonshell" ? null : var.job_execution_class
  timeout                = var.timeout
  max_retries            = var.max_retries
  security_configuration = local.create_security_configuration ? aws_glue_security_configuration.encryption[0].name : var.security_configuration
  connections            = length(var.job_connections) > 0 ? var.job_connections : null

  command {
    name            = var.job_type
    script_location = local.script_s3_location
    python_version  = var.job_type == "pythonshell" ? local.python_version : null
  }

  # Worker configuration based on job type
  dynamic "execution_property" {
    for_each = var.job_type == "glueetl" ? [1] : []
    content {
      max_concurrent_runs = var.max_concurrent_runs
    }
  }

  # Configure resources based on job type
  max_capacity = (
    # For pythonshell jobs, always use max_capacity
    var.job_type == "pythonshell" ? (
      var.max_capacity != null ? var.max_capacity : 0.0625
    ) :
    # For glueetl jobs, use max_capacity only if worker_type is not specified
    (var.job_type == "glueetl" && var.max_capacity != null && var.worker_type == null) ? var.max_capacity : null
  )

  # Worker type and number of workers only apply to glueetl jobs
  worker_type       = var.job_type == "glueetl" && var.worker_type != null ? var.worker_type : null
  number_of_workers = var.job_type == "glueetl" && var.worker_type != null ? var.number_of_workers : null

  default_arguments = local.default_arguments_with_deps

  dynamic "notification_property" {
    for_each = var.enable_job_insights && var.job_type == "glueetl" ? [1] : []
    content {
      notify_delay_after = var.notify_delay_after
    }
  }

  tags = var.tags

  # Add dependency on the S3 objects if we're uploading scripts
  depends_on = [
    aws_s3_object.glue_script,
    aws_s3_object.additional_scripts,
    aws_s3_object.python_dependencies
  ]
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