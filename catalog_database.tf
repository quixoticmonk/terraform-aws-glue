locals {
  create_catalog_database = var.create && var.create_catalog_database
}

resource "aws_glue_catalog_database" "this" {
  count = local.create_catalog_database ? 1 : 0

  name        = var.catalog_database_name != null ? "${var.prefix}${var.catalog_database_name}" : null
  description = "Glue catalog database created by Terraform"
  
  tags = var.tags
}
