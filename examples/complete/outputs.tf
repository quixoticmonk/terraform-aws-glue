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

output "security_configuration_name" {
  description = "Name of the Glue security configuration"
  value       = module.glue.security_configuration_name
}
