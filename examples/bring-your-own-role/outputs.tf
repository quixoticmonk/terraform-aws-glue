output "external_role_arn" {
  description = "ARN of external IAM role"
  value       = aws_iam_role.external.arn
}

output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue.catalog_database_name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = module.glue.crawler_name
}

output "job_name" {
  description = "Name of the Glue job"
  value       = module.glue.job_name
}
