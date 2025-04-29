provider "aws" {
  region = "us-east-1"
}

module "glue" {
  source = "../../"
  
  prefix = "pythonshell-"
  
  # IAM Role
  create_iam_role = true
  
  # S3 Bucket for scripts
  create_s3_bucket = true
  s3_bucket_name   = "pythonshell-scripts-bucket"
  
  # Glue Job
  create_job = true
  job_name   = "data-processor"
  job_type   = "pythonshell"
  glue_version = "4.0"
  
  # Local script that will be uploaded to S3
  job_script_local_path = "${path.module}/scripts/process_data.py"
  
  # PythonShell jobs use max_capacity instead of worker_type
  max_capacity = 0.0625  # Equivalent to G.025X
  
  # Job arguments
  job_default_arguments = {
    "--input_path" = "s3://example-bucket/input/"
    "--output_path" = "s3://example-bucket/output/"
  }
  
  tags = {
    Environment = "dev"
    Project     = "data-processing"
  }
}
