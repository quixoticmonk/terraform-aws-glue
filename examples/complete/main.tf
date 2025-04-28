provider "aws" {
  region = "us-west-2"
}

provider "awscc" {
  region = "us-west-2"
}

module "glue" {
  source = "../../"
  
  prefix = "demo-"
  
  # IAM Role
  create_iam_role = true
  iam_role_name   = "glue-job-role"
  
  # S3 Bucket for scripts
  create_s3_bucket = true
  s3_bucket_name   = "demo-glue-scripts-bucket"
  
  # Catalog Database
  create_catalog_database = true
  catalog_database_name   = "demo_database"
  
  # Glue Job
  create_job = true
  job_name   = "etl-job"
  job_type   = "glueetl"
  glue_version = "4.0"
  job_language = "python"
  
  # Local script that will be uploaded to S3
  job_script_local_path = "${path.module}/scripts/sample_etl_job.py"
  
  # Additional script files
  additional_script_files = {
    "scripts/utils.py" = "${path.module}/scripts/utils.py"
    "scripts/config.json" = "${path.module}/scripts/config.json"
  }
  
  # Python dependencies
  # Uncomment if you have a dependencies zip file
  # python_dependencies_local_path = "${path.module}/dependencies/python_modules.zip"
  
  # Worker configuration
  worker_type = "G.1X"
  number_of_workers = 2
  
  # Job arguments
  job_default_arguments = {
    "--database_name" = "demo_database"
    "--table_name" = "source_table"
    "--output_path" = "s3://demo-output-bucket/results/"
    "--enable-metrics" = "true"
  }
  
  # Registry
  create_registry = true
  registry_name   = "demo-registry"
  registry_description = "Schema registry for data pipeline"
  
  # Schema
  create_schema = true
  schema_name   = "demo-schema"
  schema_description = "Schema for ETL job data"
  schema_compatibility = "BACKWARD"
  schema_data_format = "AVRO"
  schema_definition = jsonencode({
    type = "record"
    name = "ProcessedData"
    namespace = "com.example.data"
    fields = [
      {
        name = "id"
        type = "string"
      },
      {
        name = "timestamp"
        type = "long"
      },
      {
        name = "value"
        type = "double"
      },
      {
        name = "category"
        type = "string"
      },
      {
        name = "processed"
        type = "boolean"
      }
    ]
  })
  
  # Schema Version
  create_schema_version = true
  
  # Schema Version Metadata
  schema_version_metadata = {
    "source" = "etl-job"
    "created_by" = "terraform"
    "version_description" = "Initial schema version for ETL job output data"
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
}

# Create a second job that uses the schema
module "schema_aware_job" {
  source = "../../"
  
  prefix = "schema-"
  
  # IAM Role - reuse the role from the first module
  create_iam_role = false
  iam_role_arn    = module.glue.iam_role_arn
  
  # Glue Job
  create_job = true
  job_name   = "schema-aware-etl-job"
  job_type   = "glueetl"
  glue_version = "4.0"
  
  # Use the S3 bucket from the first module
  create_s3_bucket = false
  existing_s3_bucket_name = module.glue.s3_bucket_id
  
  # Local script that will be uploaded to S3
  job_script_local_path = "${path.module}/scripts/schema_aware_etl_job.py"
  
  # Worker configuration
  worker_type = "G.1X"
  number_of_workers = 2
  
  # Job arguments that reference the schema registry
  job_default_arguments = {
    "--database_name" = module.glue.catalog_database_name
    "--table_name" = "source_table"
    "--output_path" = "s3://demo-output-bucket/results/"
    "--enable-metrics" = "true"
    "--schema_registry_name" = module.glue.registry_name
    "--schema_name" = module.glue.schema_name
    "--enable_schema_validation" = "true"
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
  
  depends_on = [module.glue]
}
