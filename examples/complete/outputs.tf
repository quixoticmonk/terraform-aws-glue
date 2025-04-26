output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.glue.iam_role_arn
}

output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue.catalog_database_name
}

output "connection_name" {
  description = "Name of the Glue connection"
  value       = module.glue.connection_name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = module.glue.crawler_name
}

output "job_name" {
  description = "Name of the Glue job"
  value       = module.glue.job_name
}

output "trigger_name" {
  description = "Name of the Glue trigger"
  value       = module.glue.trigger_name
}

output "workflow_name" {
  description = "Name of the Glue workflow"
  value       = module.glue.workflow_name
}

output "security_configuration_name" {
  description = "Name of the Glue security configuration"
  value       = module.glue.security_configuration_name
}

output "schema_name" {
  description = "Name of the Glue schema"
  value       = module.glue.schema_name
}

output "registry_name" {
  description = "Name of the Glue registry"
  value       = module.glue.registry_name
}
