output "registry_arn" {
  description = "ARN of the Glue registry"
  value       = module.glue.registry_arn
}

output "schema_arn" {
  description = "ARN of the Glue schema"
  value       = module.glue.schema_arn
}

output "schema_version_id" {
  description = "ID of the Glue schema version"
  value       = module.glue.schema_version_id
}

output "schema_version_only_id" {
  description = "ID of the Glue schema version created for existing schema"
  value       = module.glue_schema_version_only.schema_version_id
}
