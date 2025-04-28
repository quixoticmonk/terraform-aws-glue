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
  iam_role_name   = "glue-schema-version-role"
  
  # Registry
  create_registry = true
  registry_name   = "example-registry"
  registry_description = "Example registry created by Terraform"
  
  # Schema
  create_schema = true
  schema_name   = "example-schema"
  schema_description = "Example schema with version"
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

  # Schema Version
  create_schema_version = true
  # Using the same definition as the schema in this example
  # schema_version_definition = "..." // Optional: provide a different schema definition for the version
  
  # Schema Version Metadata
  schema_version_metadata = {
    "source"             = "etl-job"
    "created_by"         = "terraform"
    "version_description" = "Initial schema version for ETL job output data"
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
}

# Example of creating a schema version for an existing schema
module "glue_schema_version_only" {
  source = "../../"

  prefix = "existing-"
  
  # IAM Role
  create_iam_role = false
  iam_role_arn    = module.glue.iam_role_arn
  
  # Don't create registry or schema, just reference existing schema
  create_registry = false
  create_schema = false
  
  # Schema Version
  create_schema_version = true
  schema_arn = module.glue.schema_arn
  schema_version_definition = <<EOF
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
    },
    {
      "name": "status",
      "type": "string",
      "default": "pending"
    }
  ]
}
EOF
  
  schema_version_metadata = {
    "version_number" = "2"
    "updated_by"     = "terraform"
    "changes"        = "Added status field with default value"
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
  
  depends_on = [module.glue]
}
