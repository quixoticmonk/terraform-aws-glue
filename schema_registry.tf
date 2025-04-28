locals {
  create_registry = var.create && var.create_registry
  registry_name   = "${var.prefix}${var.registry_name}"

  create_schema         = var.create && var.create_schema
  schema_name           = "${var.prefix}${var.schema_name}"
  create_schema_version = var.create && var.create_schema_version && (var.create_schema || var.schema_arn != null)

}

resource "awscc_glue_registry" "this" {
  count = local.create_registry ? 1 : 0

  name        = local.registry_name
  description = var.registry_description

  tags = [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]
}

resource "awscc_glue_schema" "this" {
  count = local.create_schema ? 1 : 0

  name              = local.schema_name
  compatibility     = var.schema_compatibility
  data_format       = var.schema_data_format
  schema_definition = var.schema_definition
  description       = var.schema_description

  registry = {
    arn = var.schema_registry_arn != null ? var.schema_registry_arn : try(awscc_glue_registry.this[0].arn, "")
  }

  tags = [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]

  depends_on = [awscc_glue_registry.this]
}


resource "awscc_glue_schema_version" "this" {
  count = local.create_schema_version ? 1 : 0

  schema            = var.schema_arn != null ? var.schema_arn : try(awscc_glue_schema.this[0].arn, "")
  schema_definition = var.schema_version_definition != null ? var.schema_version_definition : var.schema_definition

  depends_on = [awscc_glue_schema.this]
}

resource "awscc_glue_schema_version_metadata" "this" {
  for_each = var.create && var.create_schema_version ? var.schema_version_metadata : {}

  key               = each.key
  value             = each.value
  schema_version_id = try(awscc_glue_schema_version.this[0].version_id, "")

  depends_on = [awscc_glue_schema_version.this]
}
