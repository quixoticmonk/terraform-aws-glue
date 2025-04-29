locals {
  create_registry = var.create && var.create_registry
  registry_name   = "${var.prefix}${var.registry_name}"

  create_schema = var.create && var.create_schema
  schema_name   = "${var.prefix}${var.schema_name}"
}

resource "awscc_glue_registry" "this" {
  count = var.create && var.create_registry ? 1 : 0

  name        = var.prefix != "" ? "${var.prefix}${var.registry_name}" : var.registry_name
  description = var.registry_description
  tags = [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]
}


resource "aws_glue_schema" "this" {
  count = local.create_schema ? 1 : 0

  schema_name       = local.schema_name
  compatibility     = var.schema_compatibility
  data_format       = var.schema_data_format
  schema_definition = var.schema_definition
  description       = var.schema_description

  registry_arn = var.schema_registry_arn != null ? var.schema_registry_arn : try(awscc_glue_registry.this[0].arn, "")

  tags = var.tags

  depends_on = [awscc_glue_registry.this]
}
