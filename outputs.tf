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

# Catalog Database outputs
output "catalog_database_id" {
  description = "ID of the Glue catalog database"
  value       = try(aws_glue_catalog_database.this[0].id, null)
}

output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = try(aws_glue_catalog_database.this[0].name, null)
}

output "catalog_database_arn" {
  description = "ARN of the Glue catalog database"
  value       = try(aws_glue_catalog_database.this[0].arn, null)
}

# Connection outputs
output "connection_id" {
  description = "ID of the Glue connection"
  value       = try(aws_glue_connection.this[0].id, null)
}

output "connection_name" {
  description = "Name of the Glue connection"
  value       = try(aws_glue_connection.this[0].name, null)
}

# Crawler outputs
output "crawler_id" {
  description = "ID of the Glue crawler"
  value       = try(aws_glue_crawler.this[0].id, null)
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = try(aws_glue_crawler.this[0].name, null)
}

output "crawler_arn" {
  description = "ARN of the Glue crawler"
  value       = try(aws_glue_crawler.this[0].arn, null)
}

# Trigger outputs
output "trigger_id" {
  description = "ID of the Glue trigger"
  value       = try(aws_glue_trigger.this[0].id, null)
}

output "trigger_name" {
  description = "Name of the Glue trigger"
  value       = try(aws_glue_trigger.this[0].name, null)
}

output "trigger_arn" {
  description = "ARN of the Glue trigger"
  value       = try(aws_glue_trigger.this[0].arn, null)
}

# Workflow outputs
output "workflow_id" {
  description = "ID of the Glue workflow"
  value       = try(aws_glue_workflow.this[0].id, null)
}

output "workflow_name" {
  description = "Name of the Glue workflow"
  value       = try(aws_glue_workflow.this[0].name, null)
}

output "workflow_arn" {
  description = "ARN of the Glue workflow"
  value       = try(aws_glue_workflow.this[0].arn, null)
}

# Registry outputs
output "registry_arn" {
  description = "ARN of the Glue registry"
  value       = try(awscc_glue_registry.this[0].arn, null)
}

output "registry_name" {
  description = "Name of the Glue registry"
  value       = try(awscc_glue_registry.this[0].name, null)
}

# Schema outputs
output "schema_arn" {
  description = "ARN of the Glue schema"
  value       = try(aws_glue_schema.this[0].arn, null)
}

output "schema_name" {
  description = "Name of the Glue schema"
  value       = try(aws_glue_schema.this[0].schema_name, null)
}
