provider "aws" {
  region = "us-east-1"
}

provider "awscc" {
  region = "us-east-1"
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
  schema_definition = jsonencode(
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
  )
  
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
  schema_registry_arn = module.glue.registry_arn
  schema_description = "Example schema that uses an existing registry"
  schema_compatibility = "BACKWARD"
  schema_data_format = "AVRO"
  schema_definition = jsonencode(
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
  )
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
  
  # Ensure this module runs after the first one
  depends_on = [module.glue]
}
