output "registry_name" {
  description = "Name of the created Glue registry"
  value       = module.glue.registry_name
}

output "registry_arn" {
  description = "ARN of the created Glue registry"
  value       = module.glue.registry_arn
}

output "schema_name" {
  description = "Name of the first Glue schema"
  value       = module.glue.schema_name
}

output "schema_arn" {
  description = "ARN of the first Glue schema"
  value       = module.glue.schema_arn
}

output "second_schema_name" {
  description = "Name of the second Glue schema (using existing registry)"
  value       = module.glue_schema_only.schema_name
}

output "second_schema_arn" {
  description = "ARN of the second Glue schema (using existing registry)"
  value       = module.glue_schema_only.schema_arn
}
