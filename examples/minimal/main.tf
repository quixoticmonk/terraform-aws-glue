provider "aws" {
  region = "us-east-1"
}

module "glue" {
  source = "../../"
  
  prefix = "minimal-"
  
  # IAM Role
  create_iam_role = true
  
  # Glue Job with S3 script
  create_job = true
  job_name   = "simple-job"
  job_type   = "glueetl"
  glue_version = "4.0"
  
  # Use existing S3 bucket and script
  create_s3_bucket = false
  existing_s3_bucket_name = "statetest-s3"
  job_script_local_path = "${path.module}/scripts/simple_job.py"
  
  # Worker configuration
  worker_type = "G.1X"
  number_of_workers = 2
  
  tags = {
    Environment = "dev"
  }
}
