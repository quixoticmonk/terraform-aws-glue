locals {
  create_trigger = var.create && var.create_trigger
  trigger_name   = "${var.prefix}${var.trigger_name}"
}

resource "aws_glue_trigger" "this" {
  count = local.create_trigger ? 1 : 0

  name        = local.trigger_name
  description = var.trigger_description
  type        = var.trigger_type
  enabled     = var.trigger_enabled
  
  schedule    = var.trigger_type == "SCHEDULED" ? var.trigger_schedule : null
  
  dynamic "actions" {
    for_each = var.trigger_actions
    content {
      job_name = actions.value.job_name
      arguments = lookup(actions.value, "arguments", null)
      timeout  = lookup(actions.value, "timeout", null)
      security_configuration = lookup(actions.value, "security_configuration", null)
      notification_property {
        notify_delay_after = lookup(actions.value, "notify_delay_after", null)
      }
    }
  }
  
  dynamic "predicate" {
    for_each = var.trigger_type == "CONDITIONAL" && var.trigger_predicate != null ? [var.trigger_predicate] : []
    content {
      logical = lookup(predicate.value, "logical", "AND")
      
      dynamic "conditions" {
        for_each = lookup(predicate.value, "conditions", [])
        content {
          job_name = lookup(conditions.value, "job_name", null)
          state    = lookup(conditions.value, "state", null)
          crawler_name = lookup(conditions.value, "crawler_name", null)
          crawl_state = lookup(conditions.value, "crawl_state", null)
        }
      }
    }
  }
  
  workflow_name = var.trigger_workflow_name
  start_on_creation = var.trigger_start_on_creation
  
  tags = var.tags
}
