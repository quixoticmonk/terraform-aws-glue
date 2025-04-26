provider "aws" {
  region = "us-west-2"
}

provider "awscc" {
  region = "us-west-2"
}

module "glue" {
  source = "../../"

  prefix = "example-"
  
  # IAM Role
  create_iam_role = true
  iam_role_name   = "glue-schema-registry-role"
  
  # Registry
  create_registry = true
  registry_name   = "example-registry"
  registry_description = "Example registry created by Terraform"
  
  # Schema
  create_schema = true
  schema_name   = "example-schema"
  schema_description = "Example schema that depends on the registry"
  schema_compatibility = "BACKWARD"
  schema_data_format = "AVRO"
  schema_definition = <<EOF
{
  "type": "record",
  "name": "ExampleRecord",
  "namespace": "com.example",
  "fields": [
    {
      "name": "id",
      "type": "string"
    },
    {
      "name": "timestamp",
      "type": "long"
    },
    {
      "name": "value",
      "type": "double"
    }
  ]
}
EOF
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
}

# Example of creating a schema that uses an existing registry
module "glue_schema_only" {
  source = "../../"

  prefix = "existing-"
  
  # IAM Role
  create_iam_role = true
  iam_role_name   = "glue-schema-only-role"
  
  # Registry - don't create, use the one from the first module
  create_registry = false
  
  # Schema
  create_schema = true
  schema_name   = "example-schema-using-existing-registry"
  schema_registry_name = module.glue.registry_name
  schema_description = "Example schema that uses an existing registry"
  schema_compatibility = "BACKWARD"
  schema_data_format = "AVRO"
  schema_definition = <<EOF
{
  "type": "record",
  "name": "AnotherRecord",
  "namespace": "com.example",
  "fields": [
    {
      "name": "id",
      "type": "string"
    },
    {
      "name": "name",
      "type": "string"
    }
  ]
}
EOF
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
  
  # Ensure this module runs after the first one
  depends_on = [module.glue]
}
