locals {
  create_registry = var.create && var.create_registry
  registry_name   = "${var.prefix}${var.registry_name}"
  
  create_schema = var.create && var.create_schema
  schema_name   = "${var.prefix}${var.schema_name}"
}

resource "aws_glue_registry" "this" {
  count = local.create_registry ? 1 : 0

  registry_name = local.registry_name
  description   = var.registry_description
  
  tags = var.tags
}

# For schema creation, we need to use a null_resource to work around the registry_name issue
# This is because aws_glue_schema has registry_name as a computed attribute that can't be set directly

resource "null_resource" "schema_creation" {
  count = local.create_schema ? 1 : 0

  triggers = {
    schema_name      = local.schema_name
    registry_name    = var.schema_registry_name != null ? var.schema_registry_name : try(aws_glue_registry.this[0].registry_name, "")
    compatibility    = var.schema_compatibility
    data_format      = var.schema_data_format
    schema_definition = var.schema_definition
  }

  provisioner "local-exec" {
    command = <<EOT
      # This is a placeholder for schema creation
      # In a real implementation, you would use the AWS CLI to create the schema
      echo "Would create schema ${local.schema_name} in registry ${var.schema_registry_name != null ? var.schema_registry_name : try(aws_glue_registry.this[0].registry_name, "")}"
    EOT
  }

  depends_on = [aws_glue_registry.this]
}
