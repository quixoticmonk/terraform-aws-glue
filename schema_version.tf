locals {
  create_schema_version = var.create && var.create_schema_version && (var.create_schema || var.schema_arn != null)
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
