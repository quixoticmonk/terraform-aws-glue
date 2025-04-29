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
    error_message = "Valid values for job_type are: glueetl or pythonshell. Ray jobs are not currently supported."
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

variable "enable_autoscaling" {
  description = "Enable autoscaling for the Glue job"
  type        = bool
  default     = false
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

variable "job_parameters" {
  description = "Job parameters to be passed to the job. These will be merged with default arguments"
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

variable "notify_delay_after" {
  description = "The number of minutes to wait after a job run starts before sending a job run delay notification"
  type        = number
  default     = 10
}

variable "max_retries" {
  description = "The maximum number of times to retry this job if it fails"
  type        = number
  default     = 0
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

# Connection
variable "create_connection" {
  description = "Controls if Glue connection should be created"
  type        = bool
  default     = false
}

variable "connection_name" {
  description = "Name of the Glue connection"
  type        = string
  default     = ""
}

variable "connection_description" {
  description = "Description of the Glue connection"
  type        = string
  default     = ""
}

variable "connection_type" {
  description = "Type of the connection. Supported are: JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM"
  type        = string
  default     = "JDBC"
}

variable "connection_properties" {
  description = "Map of connection properties"
  type        = map(string)
  default     = null
}

variable "physical_connection_requirements" {
  description = "Map of physical connection requirements"
  type        = map(any)
  default     = null
}

variable "catalog_id" {
  description = "The ID of the Data Catalog in which to create the connection"
  type        = string
  default     = null
}

# Trigger
variable "create_trigger" {
  description = "Controls if Glue trigger should be created"
  type        = bool
  default     = false
}

variable "trigger_name" {
  description = "Name of the Glue trigger"
  type        = string
  default     = ""
}

variable "trigger_description" {
  description = "Description of the Glue trigger"
  type        = string
  default     = ""
}

variable "trigger_type" {
  description = "Type of the trigger. Valid values: SCHEDULED, CONDITIONAL, ON_DEMAND, EVENT"
  type        = string
  default     = "ON_DEMAND"
}

variable "trigger_enabled" {
  description = "Whether the trigger should be enabled"
  type        = bool
  default     = true
}

variable "trigger_schedule" {
  description = "Cron expression for the schedule"
  type        = string
  default     = null
}

variable "trigger_actions" {
  description = "List of actions to be executed by the trigger"
  type        = list(map(any))
  default     = []
}

variable "trigger_predicate" {
  description = "Predicate for the trigger"
  type        = map(any)
  default     = null
}

variable "trigger_workflow_name" {
  description = "Name of the workflow associated with the trigger"
  type        = string
  default     = null
}

variable "trigger_start_on_creation" {
  description = "Whether the trigger should start on creation"
  type        = bool
  default     = false
}

# Workflow
variable "create_workflow" {
  description = "Controls if Glue workflow should be created"
  type        = bool
  default     = false
}

variable "workflow_name" {
  description = "Name of the Glue workflow"
  type        = string
  default     = ""
}

variable "workflow_description" {
  description = "Description of the Glue workflow"
  type        = string
  default     = "null"
}

variable "workflow_default_run_properties" {
  description = "Default run properties for the workflow"
  type        = map(string)
  default     = null
}

variable "workflow_max_concurrent_runs" {
  description = "Maximum number of concurrent runs for the workflow"
  type        = number
  default     = null
}

# Dev Endpoint
variable "create_dev_endpoint" {
  description = "Controls if Glue dev endpoint should be created"
  type        = bool
  default     = false
}

variable "dev_endpoint_name" {
  description = "Name of the Glue dev endpoint"
  type        = string
  default     = ""
}

variable "dev_endpoint_arguments" {
  description = "Map of arguments for the dev endpoint"
  type        = map(string)
  default     = null
}

variable "dev_endpoint_extra_jars_s3_path" {
  description = "S3 path to extra JARs for the dev endpoint"
  type        = string
  default     = null
}

variable "dev_endpoint_extra_python_libs_s3_path" {
  description = "S3 path to extra Python libraries for the dev endpoint"
  type        = string
  default     = null
}

variable "dev_endpoint_glue_version" {
  description = "Glue version for the dev endpoint"
  type        = string
  default     = null
}

variable "dev_endpoint_number_of_nodes" {
  description = "Number of nodes for the dev endpoint"
  type        = number
  default     = null
}

variable "dev_endpoint_number_of_workers" {
  description = "Number of workers for the dev endpoint"
  type        = number
  default     = null
}

variable "dev_endpoint_public_key" {
  description = "Public key for the dev endpoint"
  type        = string
  default     = null
}

variable "dev_endpoint_public_keys" {
  description = "List of public keys for the dev endpoint"
  type        = list(string)
  default     = null
}

variable "dev_endpoint_security_configuration" {
  description = "Security configuration for the dev endpoint"
  type        = string
  default     = null
}

variable "dev_endpoint_security_group_ids" {
  description = "List of security group IDs for the dev endpoint"
  type        = list(string)
  default     = null
}

variable "dev_endpoint_subnet_id" {
  description = "Subnet ID for the dev endpoint"
  type        = string
  default     = null
}

variable "dev_endpoint_worker_type" {
  description = "Worker type for the dev endpoint"
  type        = string
  default     = null
}

# Schema Registry
variable "create_registry" {
  description = "Controls if Glue registry should be created"
  type        = bool
  default     = false
}

variable "registry_name" {
  description = "Name of the Glue registry"
  type        = string
  default     = ""
}

variable "registry_description" {
  description = "Description of the Glue registry"
  type        = string
  default     = ""
}

# Schema
variable "create_schema" {
  description = "Controls if Glue schema should be created"
  type        = bool
  default     = false
}

variable "schema_name" {
  description = "Name of the Glue schema"
  type        = string
  default     = ""
}

variable "schema_registry_arn" {
  description = "ARN of an existing registry to use for the schema"
  type        = string
  default     = null
}

variable "schema_description" {
  description = "Description of the Glue schema"
  type        = string
  default     = null
}

variable "schema_compatibility" {
  description = "Compatibility mode of the schema. Valid values: NONE, DISABLED, BACKWARD, BACKWARD_ALL, FORWARD, FORWARD_ALL, FULL, FULL_ALL"
  type        = string
  default     = "NONE"
}

variable "schema_data_format" {
  description = "Data format of the schema. Valid values: AVRO, JSON, PROTOBUF"
  type        = string
  default     = "AVRO"
}

variable "schema_definition" {
  description = "Schema definition as a JSON string"
  type        = string
  default     = null
}

variable "schema_arn" {
  description = "ARN of an existing schema to use"
  type        = string
  default     = null
}
