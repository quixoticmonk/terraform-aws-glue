locals {
  create_dev_endpoint = var.create && var.create_dev_endpoint
  dev_endpoint_name   = "${var.prefix}${var.dev_endpoint_name}"
}

resource "aws_glue_dev_endpoint" "this" {
  count = local.create_dev_endpoint ? 1 : 0

  name                   = local.dev_endpoint_name
  role_arn               = var.create_iam_role ? aws_iam_role.glue[0].arn : var.iam_role_arn
  
  arguments              = var.dev_endpoint_arguments
  extra_jars_s3_path     = var.dev_endpoint_extra_jars_s3_path
  extra_python_libs_s3_path = var.dev_endpoint_extra_python_libs_s3_path
  glue_version           = var.dev_endpoint_glue_version
  number_of_nodes        = var.dev_endpoint_number_of_nodes
  number_of_workers      = var.dev_endpoint_number_of_workers
  public_key             = var.dev_endpoint_public_key
  public_keys            = var.dev_endpoint_public_keys
  security_configuration = var.dev_endpoint_security_configuration
  security_group_ids     = var.dev_endpoint_security_group_ids
  subnet_id              = var.dev_endpoint_subnet_id
  worker_type            = var.dev_endpoint_worker_type
  
  tags = var.tags
}
