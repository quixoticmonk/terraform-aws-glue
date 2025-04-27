locals {
  create_connection = var.create && var.create_connection
  connection_name   = "${var.prefix}${var.connection_name}"
}

resource "aws_glue_connection" "this" {
  count = local.create_connection ? 1 : 0

  name        = local.connection_name
  description = var.connection_description
  
  connection_type = var.connection_type
  
  connection_properties = var.connection_properties
  
  dynamic "physical_connection_requirements" {
    for_each = var.physical_connection_requirements != null ? [var.physical_connection_requirements] : []
    content {
      availability_zone      = lookup(physical_connection_requirements.value, "availability_zone", null)
      security_group_id_list = lookup(physical_connection_requirements.value, "security_group_id_list", null)
      subnet_id              = lookup(physical_connection_requirements.value, "subnet_id", null)
    }
  }

  catalog_id = var.catalog_id
  
  tags = var.tags
}
