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
  
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
}
