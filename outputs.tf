output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = var.create_iam_role ? aws_iam_role.glue[0].arn : var.iam_role_arn
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = var.create_iam_role ? aws_iam_role.glue[0].name : null
}

output "job_id" {
  description = "ID of the Glue job"
  value       = try(aws_glue_job.this[0].id, null)
}

output "job_name" {
  description = "Name of the Glue job"
  value       = try(aws_glue_job.this[0].name, null)
}

output "job_arn" {
  description = "ARN of the Glue job"
  value       = try(aws_glue_job.this[0].arn, null)
}

output "job_script_s3_location" {
  description = "S3 location of the Glue job script"
  value       = local.script_s3_location
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket storing Glue scripts"
  value       = try(aws_s3_bucket.glue_scripts[0].id, null)
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket storing Glue scripts"
  value       = try(aws_s3_bucket.glue_scripts[0].arn, null)
}

output "security_configuration_id" {
  description = "ID of the Glue security configuration"
  value       = try(aws_glue_security_configuration.encryption[0].id, null)
}

output "security_configuration_name" {
  description = "Name of the Glue security configuration"
  value       = try(aws_glue_security_configuration.encryption[0].name, null)
}
