locals {
  create_crawler = var.create && var.create_crawler
}

resource "aws_glue_crawler" "this" {
  count = local.create_crawler ? 1 : 0

  name          = var.crawler_name != null ? "${var.prefix}${var.crawler_name}" : null
  role          = var.create_iam_role ? aws_iam_role.glue[0].arn : var.iam_role_arn
  database_name = var.create_catalog_database ? aws_glue_catalog_database.this[0].name : null

  dynamic "s3_target" {
    for_each = var.crawler_s3_targets
    content {
      path = s3_target.value.path
    }
  }

  tags = var.tags
}
