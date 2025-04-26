output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.glue.iam_role_arn
}

output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.glue.catalog_database_name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = module.glue.crawler_name
}
