variable "create" {
  description = "Controls if resources should be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  description = "Prefix to be used for all resources"
  type        = string
  default     = ""
}

# IAM Role
variable "create_iam_role" {
  description = "Controls if IAM role should be created"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name of the IAM role for Glue resources"
  type        = string
  default     = null
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the Glue resources"
  type        = string
  default     = ""
}

# Glue Job
variable "create_job" {
  description = "Controls if Glue job should be created"
  type        = bool
  default     = false
}

variable "job_name" {
  description = "Name of the Glue job"
  type        = string
  default     = null
}

variable "job_description" {
  description = "Description of the Glue job"
  type        = string
  default     = null
}

variable "job_type" {
  description = "The type of job. Valid values are: 'glueetl' or 'pythonshell'"
  type        = string
  default     = "glueetl"
  validation {
    condition     = contains(["glueetl", "pythonshell"], var.job_type)
    error_message = "Valid values for job_type are: glueetl or pythonshell."
  }
}

variable "glue_version" {
  description = "The version of Glue to use"
  type        = string
  default     = "4.0"
  validation {
    condition     = contains(["3.0", "4.0", "5.0"], var.glue_version)
    error_message = "Valid values for glue_version are: 3.0, 4.0, or 5.0."
  }
}

variable "job_command_script_location" {
  description = "S3 location of the script to be executed. Only used if job_script_local_path is not provided"
  type        = string
  default     = null
}

variable "job_language" {
  description = "The script programming language. Valid values: scala, python"
  type        = string
  default     = "python"
  validation {
    condition     = contains(["python", "scala"], var.job_language)
    error_message = "Valid values for job_language are: python or scala."
  }
}

variable "python_version" {
  description = "The Python version to use. If not specified, it will be determined based on Glue version"
  type        = string
  default     = null
}

variable "max_capacity" {
  description = "The maximum capacity for this job. Used only for Glue ETL jobs"
  type        = number
  default     = null
}

variable "worker_type" {
  description = "The type of worker to use. Valid values: Standard, G.1X, G.2X, G.4X, G.8X, G.025X"
  type        = string
  default     = null
}

variable "number_of_workers" {
  description = "The number of workers to use for the job"
  type        = number
  default     = null
}

variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for this job"
  type        = number
  default     = 1
}

variable "timeout" {
  description = "The job timeout in minutes"
  type        = number
  default     = 2880 # 48 hours
}

variable "job_default_arguments" {
  description = "Default arguments for the job"
  type        = map(string)
  default     = {}
}

variable "job_connections" {
  description = "List of connections to use for the job"
  type        = list(string)
  default     = []
}

variable "job_execution_class" {
  description = "Indicates whether the job is run with a standard or flexible execution class"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "FLEX"], var.job_execution_class)
    error_message = "Valid values for job_execution_class are: STANDARD or FLEX."
  }
}

variable "enable_job_insights" {
  description = "Specifies whether job insights are enabled for the job"
  type        = bool
  default     = false
}

variable "security_configuration" {
  description = "The name of the Security Configuration to be associated with the job"
  type        = string
  default     = null
}

# S3 Bucket for Scripts
variable "create_s3_bucket" {
  description = "Controls if S3 bucket should be created for Glue scripts"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store Glue scripts. If not provided and create_s3_bucket is true, a name will be generated"
  type        = string
  default     = null
}

variable "existing_s3_bucket_name" {
  description = "Name of an existing S3 bucket to store Glue scripts. Used when create_s3_bucket is false"
  type        = string
  default     = null
}

variable "job_script_local_path" {
  description = "Local path to the Glue job script in the repository"
  type        = string
  default     = null
}

variable "job_script_s3_key" {
  description = "S3 key where the job script will be uploaded. If not provided, the filename from job_script_local_path will be used"
  type        = string
  default     = null
}

variable "s3_bucket_force_destroy" {
  description = "Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed"
  type        = bool
  default     = false
}

variable "s3_bucket_tags" {
  description = "A map of tags to assign to the S3 bucket"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_kms_key_arn" {
  description = "ARN of KMS key to use for S3 bucket encryption"
  type        = string
  default     = null
}

variable "additional_script_files" {
  description = "Map of additional script files to upload to S3. The key is the S3 object key and the value is the local file path"
  type        = map(string)
  default     = {}
}

variable "python_dependencies_local_path" {
  description = "Local path to a zip file containing Python dependencies for the job"
  type        = string
  default     = null
}

variable "python_dependencies_s3_key" {
  description = "S3 key where the Python dependencies zip will be uploaded"
  type        = string
  default     = "dependencies/python_modules.zip"
}

# Encryption Configuration
variable "enable_s3_encryption" {
  description = "Enable server-side encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_kms_key_arn" {
  description = "ARN of KMS key to use for S3 bucket encryption. If not provided, AES256 encryption will be used"
  type        = string
  default     = null
}

variable "enable_job_bookmarks_encryption" {
  description = "Enable encryption for job bookmarks"
  type        = bool
  default     = false
}

variable "job_bookmarks_encryption_kms_key_arn" {
  description = "ARN of KMS key to use for job bookmarks encryption"
  type        = string
  default     = null
}

variable "enable_cloudwatch_encryption" {
  description = "Enable encryption for CloudWatch logs"
  type        = bool
  default     = false
}

variable "cloudwatch_encryption_kms_key_arn" {
  description = "ARN of KMS key to use for CloudWatch logs encryption"
  type        = string
  default     = null
}

# Catalog Database
variable "create_catalog_database" {
  description = "Controls if Glue catalog database should be created"
  type        = bool
  default     = false
}

variable "catalog_database_name" {
  description = "Name of the Glue catalog database"
  type        = string
  default     = null
}

# Crawler
variable "create_crawler" {
  description = "Controls if Glue crawler should be created"
  type        = bool
  default     = false
}

variable "crawler_name" {
  description = "Name of the Glue crawler"
  type        = string
  default     = null
}

variable "crawler_s3_targets" {
  description = "List of S3 targets for the crawler"
  type        = list(map(string))
  default     = []
}
