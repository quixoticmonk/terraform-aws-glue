output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.glue.iam_role_arn
}

output "job_name" {
  description = "Name of the Glue job"
  value       = module.glue.job_name
}

output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue.catalog_database_name
}

output "registry_name" {
  description = "Name of the Glue registry"
  value       = module.glue.registry_name
}

output "registry_arn" {
  description = "ARN of the Glue registry"
  value       = module.glue.registry_arn
}

output "schema_name" {
  description = "Name of the Glue schema"
  value       = module.glue.schema_name
}

output "schema_arn" {
  description = "ARN of the Glue schema"
  value       = module.glue.schema_arn
}

output "schema_aware_job_name" {
  description = "Name of the schema-aware Glue job"
  value       = module.schema_aware_job.job_name
}
