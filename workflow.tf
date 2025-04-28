locals {
  create_workflow = var.create && var.create_workflow
  workflow_name   = "${var.prefix}${var.workflow_name}"
}

resource "aws_glue_workflow" "this" {
  count = local.create_workflow ? 1 : 0

  name        = local.workflow_name
  description = var.workflow_description

  default_run_properties = var.workflow_default_run_properties
  max_concurrent_runs    = var.workflow_max_concurrent_runs

  tags = var.tags
}
