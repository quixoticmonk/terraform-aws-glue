<!-- BEGIN_TF_DOCS -->
# AWS Glue Terraform module

Terraform module which creates AWS Glue resources using both AWS and AWSCC providers.

## Usage

```hcl
module "glue" {
  source = "terraform-aws-modules/glue/aws"

  prefix = "example-"
  # IAM Role
  create_iam_role = true
  iam_role_name   = "example-glue-role"
  # Catalog Database
  create_catalog_database = true
  catalog_database_name   = "example_database"
  # Crawler
  create_crawler = true
  crawler_name   = "example-crawler"
  crawler_s3_targets = [
    {
      path = "s3://example-bucket/example-path"
    }
  ]
  # Job with S3 script upload
  create_job = true
  job_name   = "example-job"
  job_type   = "glueetl"
  glue_version = "4.0"
  # Option 1: Use existing S3 script location
  job_command_script_location = "s3://example-bucket/scripts/example-job.py"
  # Option 2: Upload local script to S3
  create_s3_bucket = true
  job_script_local_path = "${path.module}/scripts/example-job.py"
```

### GlueETL Jobs
```hcl
module "glue_etl_job" {
  source = "terraform-aws-modules/glue/aws"

  # Basic configuration
  prefix = "etl-"
  create_job = true
  job_name = "data-transformation"
  job_type = "glueetl"
  glue_version = "4.0"
  timeout = 60
  max_retries = 2
  # Worker configuration
  worker_type = "G.1X"
  number_of_workers = 2
  # Autoscaling configuration (only for glueetl jobs)
  enable_autoscaling = true
  # Job insights (only for glueetl jobs)
  enable_job_insights = true
  notify_delay_after = 15
  # Job parameters
  job_parameters = {
    "--conf" = "spark.dynamicAllocation.enabled=true"
  }
}
```

### PythonShell Jobs
```hcl
module "glue_python_job" {
  source = "terraform-aws-modules/glue/aws"

  # Basic configuration
  prefix = "python-"
  create_job = true
  job_name = "data-processing"
  job_type = "pythonshell"
  # PythonShell jobs use max_capacity instead of worker_type/number_of_workers
  max_capacity = 0.0625  # Equivalent to G.025X
  # Note: Python version (3.9) is automatically set for PythonShell jobs
  # Job parameters
  job_parameters = {
    "--my-param" = "my-value"
  }
}
```
  # Encryption configuration
  enable\_s3\_encryption = true
  s3\_kms\_key\_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  enable\_job\_bookmarks\_encryption = true
  job\_bookmarks\_encryption\_kms\_key\_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  enable\_cloudwatch\_encryption = true
  cloudwatch\_encryption\_kms\_key\_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  tags = {
    Environment = "dev"
    Project     = "data-pipeline"
  }
}
```

## Examples

- [Complete](examples/complete) - Complete example with all supported resources
- [Minimal](examples/minimal) - Minimal example with only basic job configuration
- [PythonShell](examples/pythonshell) - Example using PythonShell job type
- [Schema Registry Dependency](examples/schema-registry-dependency) - Example showing schema registry dependencies

## Features

This module supports the following AWS Glue resources:

### AWS Provider Resources
- AWS Glue Catalog Database
- AWS Glue Connection
- AWS Glue Crawler
- AWS Glue Job
- AWS Glue Trigger
- AWS Glue Workflow
- AWS Glue Security Configuration
- AWS Glue Dev Endpoint
- IAM Role for Glue resources
- AWS Glue Schema

### AWSCC Provider Resources
- AWSCC Glue Registry

## Module Configuration

### Common Features

- **Resource Creation Control**: Each resource has a boolean flag to control its creation (e.g., `create_catalog_database`, `create_job`)
- **Resource Naming**: Supports adding a prefix to all resource names via the `prefix` variable
- **Tagging**: Apply consistent tags to all resources via the `tags` variable
- **IAM Role Management**: Option to bring your own IAM role or create one within the module

### IAM Role

The module can either create an IAM role for Glue resources or use an existing one:

- Set `create_iam_role = true` to create a new role (default)
- Set `create_iam_role = false` and provide `iam_role_arn` to use an existing role

### Glue Job Configuration

The module supports creating AWS Glue jobs with various configurations:

#### Job Types

This module currently supports the following AWS Glue job types:
- **GlueETL (`glueetl`)**: For Spark-based ETL jobs
- **PythonShell (`pythonshell`)**: For lightweight Python scripts

> **Note:** Ray jobs are not currently supported by this module.

#### Glue Versions
- **Glue 3.0**: Based on Apache Spark 3.1.1, Python 3.7
- **Glue 4.0**: Based on Apache Spark 3.3.0, Python 3.10
- **Glue 5.0**: Based on Apache Spark 3.4.1, Python 3.11

#### Worker Types
- **Standard**: For general purpose workloads
- **G.1X**: 1 DPU (4 vCPU, 16GB memory)
- **G.2X**: 2 DPU (8 vCPU, 32GB memory)
- **G.4X**: 4 DPU (16 vCPU, 64GB memory)
- **G.8X**: 8 DPU (32 vCPU, 128GB memory)
- **G.025X**: 0.25 DPU (2 vCPU, 4GB memory) - For PythonShell jobs

### Glue Job Script Management

The module supports two approaches for providing Glue job scripts:

#### 1. Direct S3 Path Reference
Provide an existing S3 path to your script:

```hcl
module "glue" {
  source = "terraform-aws-modules/glue/aws"

  # ... other configuration ...
  create\_job = true
  job\_name   = "example-job"
  job\_command\_script\_location = "s3://my-existing-bucket/scripts/my-job.py"
}
```

#### 2. Local Script Upload
Provide a local script from your repository that will be uploaded to S3:

```hcl
module "glue" {
  source = "terraform-aws-modules/glue/aws"

  # ... other configuration ...
  create\_job = true
  job\_name   = "example-job"
  # Option 1: Create a new S3 bucket for scripts
  create\_s3\_bucket = true
  s3\_bucket\_name   = "my-glue-scripts-bucket" # Optional, generated if not provided
  # Option 2: Use an existing S3 bucket
  create\_s3\_bucket      = false
  existing\_s3\_bucket\_name = "my-existing-bucket"
  # Local script path and optional S3 key
  job\_script\_local\_path = "${path.module}/scripts/my-job.py"
  job\_script\_s3\_key     = "custom/path/my-job.py" # Optional, defaults to scripts/filename
}
```

This approach automatically:
1. Creates an S3 bucket if requested
2. Uploads your local script to the specified S3 bucket
3. Sets the correct S3 path in the Glue job configuration
4. Tracks script changes using file checksums for proper updates
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_glue_catalog_database.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_connection) | resource |
| [aws_glue_crawler.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_glue_dev_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_dev_endpoint) | resource |
| [aws_glue_job.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job) | resource |
| [aws_glue_schema.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_schema) | resource |
| [aws_glue_security_configuration.encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) | resource |
| [aws_glue_trigger.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger) | resource |
| [aws_glue_workflow.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_workflow) | resource |
| [aws_iam_policy.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.glue_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.glue_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.glue_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_object.additional_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.glue_script](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.python_dependencies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [awscc_glue_registry.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/glue_registry) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_script_files"></a> [additional\_script\_files](#input\_additional\_script\_files) | Map of additional script files to upload to S3. The key is the S3 object key and the value is the local file path | `map(string)` | `{}` | no |
| <a name="input_catalog_database_name"></a> [catalog\_database\_name](#input\_catalog\_database\_name) | Name of the Glue catalog database | `string` | `null` | no |
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | The ID of the Data Catalog in which to create the connection | `string` | `null` | no |
| <a name="input_cloudwatch_encryption_kms_key_arn"></a> [cloudwatch\_encryption\_kms\_key\_arn](#input\_cloudwatch\_encryption\_kms\_key\_arn) | ARN of KMS key to use for CloudWatch logs encryption | `string` | `null` | no |
| <a name="input_connection_description"></a> [connection\_description](#input\_connection\_description) | Description of the Glue connection | `string` | `""` | no |
| <a name="input_connection_name"></a> [connection\_name](#input\_connection\_name) | Name of the Glue connection | `string` | `""` | no |
| <a name="input_connection_properties"></a> [connection\_properties](#input\_connection\_properties) | Map of connection properties | `map(string)` | `null` | no |
| <a name="input_connection_type"></a> [connection\_type](#input\_connection\_type) | Type of the connection. Supported are: JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM | `string` | `"JDBC"` | no |
| <a name="input_crawler_name"></a> [crawler\_name](#input\_crawler\_name) | Name of the Glue crawler | `string` | `null` | no |
| <a name="input_crawler_s3_targets"></a> [crawler\_s3\_targets](#input\_crawler\_s3\_targets) | List of S3 targets for the crawler | `list(map(string))` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_catalog_database"></a> [create\_catalog\_database](#input\_create\_catalog\_database) | Controls if Glue catalog database should be created | `bool` | `false` | no |
| <a name="input_create_connection"></a> [create\_connection](#input\_create\_connection) | Controls if Glue connection should be created | `bool` | `false` | no |
| <a name="input_create_crawler"></a> [create\_crawler](#input\_create\_crawler) | Controls if Glue crawler should be created | `bool` | `false` | no |
| <a name="input_create_dev_endpoint"></a> [create\_dev\_endpoint](#input\_create\_dev\_endpoint) | Controls if Glue dev endpoint should be created | `bool` | `false` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Controls if IAM role should be created | `bool` | `true` | no |
| <a name="input_create_job"></a> [create\_job](#input\_create\_job) | Controls if Glue job should be created | `bool` | `false` | no |
| <a name="input_create_registry"></a> [create\_registry](#input\_create\_registry) | Controls if Glue registry should be created | `bool` | `false` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Controls if S3 bucket should be created for Glue scripts | `bool` | `false` | no |
| <a name="input_create_schema"></a> [create\_schema](#input\_create\_schema) | Controls if Glue schema should be created | `bool` | `false` | no |
| <a name="input_create_trigger"></a> [create\_trigger](#input\_create\_trigger) | Controls if Glue trigger should be created | `bool` | `false` | no |
| <a name="input_create_workflow"></a> [create\_workflow](#input\_create\_workflow) | Controls if Glue workflow should be created | `bool` | `false` | no |
| <a name="input_dev_endpoint_arguments"></a> [dev\_endpoint\_arguments](#input\_dev\_endpoint\_arguments) | Map of arguments for the dev endpoint | `map(string)` | `null` | no |
| <a name="input_dev_endpoint_extra_jars_s3_path"></a> [dev\_endpoint\_extra\_jars\_s3\_path](#input\_dev\_endpoint\_extra\_jars\_s3\_path) | S3 path to extra JARs for the dev endpoint | `string` | `null` | no |
| <a name="input_dev_endpoint_extra_python_libs_s3_path"></a> [dev\_endpoint\_extra\_python\_libs\_s3\_path](#input\_dev\_endpoint\_extra\_python\_libs\_s3\_path) | S3 path to extra Python libraries for the dev endpoint | `string` | `null` | no |
| <a name="input_dev_endpoint_glue_version"></a> [dev\_endpoint\_glue\_version](#input\_dev\_endpoint\_glue\_version) | Glue version for the dev endpoint | `string` | `null` | no |
| <a name="input_dev_endpoint_name"></a> [dev\_endpoint\_name](#input\_dev\_endpoint\_name) | Name of the Glue dev endpoint | `string` | `""` | no |
| <a name="input_dev_endpoint_number_of_nodes"></a> [dev\_endpoint\_number\_of\_nodes](#input\_dev\_endpoint\_number\_of\_nodes) | Number of nodes for the dev endpoint | `number` | `null` | no |
| <a name="input_dev_endpoint_number_of_workers"></a> [dev\_endpoint\_number\_of\_workers](#input\_dev\_endpoint\_number\_of\_workers) | Number of workers for the dev endpoint | `number` | `null` | no |
| <a name="input_dev_endpoint_public_key"></a> [dev\_endpoint\_public\_key](#input\_dev\_endpoint\_public\_key) | Public key for the dev endpoint | `string` | `null` | no |
| <a name="input_dev_endpoint_public_keys"></a> [dev\_endpoint\_public\_keys](#input\_dev\_endpoint\_public\_keys) | List of public keys for the dev endpoint | `list(string)` | `null` | no |
| <a name="input_dev_endpoint_security_configuration"></a> [dev\_endpoint\_security\_configuration](#input\_dev\_endpoint\_security\_configuration) | Security configuration for the dev endpoint | `string` | `null` | no |
| <a name="input_dev_endpoint_security_group_ids"></a> [dev\_endpoint\_security\_group\_ids](#input\_dev\_endpoint\_security\_group\_ids) | List of security group IDs for the dev endpoint | `list(string)` | `null` | no |
| <a name="input_dev_endpoint_subnet_id"></a> [dev\_endpoint\_subnet\_id](#input\_dev\_endpoint\_subnet\_id) | Subnet ID for the dev endpoint | `string` | `null` | no |
| <a name="input_dev_endpoint_worker_type"></a> [dev\_endpoint\_worker\_type](#input\_dev\_endpoint\_worker\_type) | Worker type for the dev endpoint | `string` | `null` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable autoscaling for the Glue job | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_encryption"></a> [enable\_cloudwatch\_encryption](#input\_enable\_cloudwatch\_encryption) | Enable encryption for CloudWatch logs | `bool` | `false` | no |
| <a name="input_enable_job_bookmarks_encryption"></a> [enable\_job\_bookmarks\_encryption](#input\_enable\_job\_bookmarks\_encryption) | Enable encryption for job bookmarks | `bool` | `false` | no |
| <a name="input_enable_job_insights"></a> [enable\_job\_insights](#input\_enable\_job\_insights) | Specifies whether job insights are enabled for the job | `bool` | `false` | no |
| <a name="input_enable_s3_encryption"></a> [enable\_s3\_encryption](#input\_enable\_s3\_encryption) | Enable server-side encryption for the S3 bucket | `bool` | `true` | no |
| <a name="input_existing_s3_bucket_name"></a> [existing\_s3\_bucket\_name](#input\_existing\_s3\_bucket\_name) | Name of an existing S3 bucket to store Glue scripts. Used when create\_s3\_bucket is false | `string` | `null` | no |
| <a name="input_glue_version"></a> [glue\_version](#input\_glue\_version) | The version of Glue to use | `string` | `"4.0"` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the Glue resources | `string` | `""` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role for Glue resources | `string` | `null` | no |
| <a name="input_job_bookmarks_encryption_kms_key_arn"></a> [job\_bookmarks\_encryption\_kms\_key\_arn](#input\_job\_bookmarks\_encryption\_kms\_key\_arn) | ARN of KMS key to use for job bookmarks encryption | `string` | `null` | no |
| <a name="input_job_command_script_location"></a> [job\_command\_script\_location](#input\_job\_command\_script\_location) | S3 location of the script to be executed. Only used if job\_script\_local\_path is not provided | `string` | `null` | no |
| <a name="input_job_connections"></a> [job\_connections](#input\_job\_connections) | List of connections to use for the job | `list(string)` | `[]` | no |
| <a name="input_job_default_arguments"></a> [job\_default\_arguments](#input\_job\_default\_arguments) | Default arguments for the job | `map(string)` | `{}` | no |
| <a name="input_job_description"></a> [job\_description](#input\_job\_description) | Description of the Glue job | `string` | `null` | no |
| <a name="input_job_execution_class"></a> [job\_execution\_class](#input\_job\_execution\_class) | Indicates whether the job is run with a standard or flexible execution class | `string` | `"STANDARD"` | no |
| <a name="input_job_language"></a> [job\_language](#input\_job\_language) | The script programming language. Valid values: scala, python | `string` | `"python"` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | Name of the Glue job | `string` | `null` | no |
| <a name="input_job_parameters"></a> [job\_parameters](#input\_job\_parameters) | Job parameters to be passed to the job. These will be merged with default arguments | `map(string)` | `{}` | no |
| <a name="input_job_script_local_path"></a> [job\_script\_local\_path](#input\_job\_script\_local\_path) | Local path to the Glue job script in the repository | `string` | `null` | no |
| <a name="input_job_script_s3_key"></a> [job\_script\_s3\_key](#input\_job\_script\_s3\_key) | S3 key where the job script will be uploaded. If not provided, the filename from job\_script\_local\_path will be used | `string` | `null` | no |
| <a name="input_job_type"></a> [job\_type](#input\_job\_type) | The type of job. Valid values are: 'glueetl' or 'pythonshell' | `string` | `"glueetl"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum capacity for this job. Used only for Glue ETL jobs | `number` | `null` | no |
| <a name="input_max_concurrent_runs"></a> [max\_concurrent\_runs](#input\_max\_concurrent\_runs) | The maximum number of concurrent runs allowed for this job | `number` | `1` | no |
| <a name="input_max_retries"></a> [max\_retries](#input\_max\_retries) | The maximum number of times to retry this job if it fails | `number` | `0` | no |
| <a name="input_notify_delay_after"></a> [notify\_delay\_after](#input\_notify\_delay\_after) | The number of minutes to wait after a job run starts before sending a job run delay notification | `number` | `10` | no |
| <a name="input_number_of_workers"></a> [number\_of\_workers](#input\_number\_of\_workers) | The number of workers to use for the job | `number` | `null` | no |
| <a name="input_physical_connection_requirements"></a> [physical\_connection\_requirements](#input\_physical\_connection\_requirements) | Map of physical connection requirements | `map(any)` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be used for all resources | `string` | `""` | no |
| <a name="input_python_dependencies_local_path"></a> [python\_dependencies\_local\_path](#input\_python\_dependencies\_local\_path) | Local path to a zip file containing Python dependencies for the job | `string` | `null` | no |
| <a name="input_python_dependencies_s3_key"></a> [python\_dependencies\_s3\_key](#input\_python\_dependencies\_s3\_key) | S3 key where the Python dependencies zip will be uploaded | `string` | `"dependencies/python_modules.zip"` | no |
| <a name="input_registry_description"></a> [registry\_description](#input\_registry\_description) | Description of the Glue registry | `string` | `""` | no |
| <a name="input_registry_name"></a> [registry\_name](#input\_registry\_name) | Name of the Glue registry | `string` | `""` | no |
| <a name="input_s3_bucket_force_destroy"></a> [s3\_bucket\_force\_destroy](#input\_s3\_bucket\_force\_destroy) | Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed | `bool` | `false` | no |
| <a name="input_s3_bucket_kms_key_arn"></a> [s3\_bucket\_kms\_key\_arn](#input\_s3\_bucket\_kms\_key\_arn) | ARN of KMS key to use for S3 bucket encryption | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket to store Glue scripts. If not provided and create\_s3\_bucket is true, a name will be generated | `string` | `null` | no |
| <a name="input_s3_bucket_tags"></a> [s3\_bucket\_tags](#input\_s3\_bucket\_tags) | A map of tags to assign to the S3 bucket | `map(string)` | `{}` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | ARN of KMS key to use for S3 bucket encryption. If not provided, AES256 encryption will be used | `string` | `null` | no |
| <a name="input_schema_arn"></a> [schema\_arn](#input\_schema\_arn) | ARN of an existing schema to use | `string` | `null` | no |
| <a name="input_schema_compatibility"></a> [schema\_compatibility](#input\_schema\_compatibility) | Compatibility mode of the schema. Valid values: NONE, DISABLED, BACKWARD, BACKWARD\_ALL, FORWARD, FORWARD\_ALL, FULL, FULL\_ALL | `string` | `"NONE"` | no |
| <a name="input_schema_data_format"></a> [schema\_data\_format](#input\_schema\_data\_format) | Data format of the schema. Valid values: AVRO, JSON, PROTOBUF | `string` | `"AVRO"` | no |
| <a name="input_schema_definition"></a> [schema\_definition](#input\_schema\_definition) | Schema definition as a JSON string | `string` | `null` | no |
| <a name="input_schema_description"></a> [schema\_description](#input\_schema\_description) | Description of the Glue schema | `string` | `null` | no |
| <a name="input_schema_name"></a> [schema\_name](#input\_schema\_name) | Name of the Glue schema | `string` | `""` | no |
| <a name="input_schema_registry_arn"></a> [schema\_registry\_arn](#input\_schema\_registry\_arn) | ARN of an existing registry to use for the schema | `string` | `null` | no |
| <a name="input_security_configuration"></a> [security\_configuration](#input\_security\_configuration) | The name of the Security Configuration to be associated with the job | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The job timeout in minutes | `number` | `2880` | no |
| <a name="input_trigger_actions"></a> [trigger\_actions](#input\_trigger\_actions) | List of actions to be executed by the trigger | `list(map(any))` | `[]` | no |
| <a name="input_trigger_description"></a> [trigger\_description](#input\_trigger\_description) | Description of the Glue trigger | `string` | `""` | no |
| <a name="input_trigger_enabled"></a> [trigger\_enabled](#input\_trigger\_enabled) | Whether the trigger should be enabled | `bool` | `true` | no |
| <a name="input_trigger_name"></a> [trigger\_name](#input\_trigger\_name) | Name of the Glue trigger | `string` | `""` | no |
| <a name="input_trigger_predicate"></a> [trigger\_predicate](#input\_trigger\_predicate) | Predicate for the trigger | `map(any)` | `null` | no |
| <a name="input_trigger_schedule"></a> [trigger\_schedule](#input\_trigger\_schedule) | Cron expression for the schedule | `string` | `null` | no |
| <a name="input_trigger_start_on_creation"></a> [trigger\_start\_on\_creation](#input\_trigger\_start\_on\_creation) | Whether the trigger should start on creation | `bool` | `false` | no |
| <a name="input_trigger_type"></a> [trigger\_type](#input\_trigger\_type) | Type of the trigger. Valid values: SCHEDULED, CONDITIONAL, ON\_DEMAND, EVENT | `string` | `"ON_DEMAND"` | no |
| <a name="input_trigger_workflow_name"></a> [trigger\_workflow\_name](#input\_trigger\_workflow\_name) | Name of the workflow associated with the trigger | `string` | `null` | no |
| <a name="input_worker_type"></a> [worker\_type](#input\_worker\_type) | The type of worker to use. Valid values: Standard, G.1X, G.2X, G.4X, G.8X, G.025X | `string` | `null` | no |
| <a name="input_workflow_default_run_properties"></a> [workflow\_default\_run\_properties](#input\_workflow\_default\_run\_properties) | Default run properties for the workflow | `map(string)` | `null` | no |
| <a name="input_workflow_description"></a> [workflow\_description](#input\_workflow\_description) | Description of the Glue workflow | `string` | `"null"` | no |
| <a name="input_workflow_max_concurrent_runs"></a> [workflow\_max\_concurrent\_runs](#input\_workflow\_max\_concurrent\_runs) | Maximum number of concurrent runs for the workflow | `number` | `null` | no |
| <a name="input_workflow_name"></a> [workflow\_name](#input\_workflow\_name) | Name of the Glue workflow | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_catalog_database_arn"></a> [catalog\_database\_arn](#output\_catalog\_database\_arn) | ARN of the Glue catalog database |
| <a name="output_catalog_database_id"></a> [catalog\_database\_id](#output\_catalog\_database\_id) | ID of the Glue catalog database |
| <a name="output_catalog_database_name"></a> [catalog\_database\_name](#output\_catalog\_database\_name) | Name of the Glue catalog database |
| <a name="output_connection_id"></a> [connection\_id](#output\_connection\_id) | ID of the Glue connection |
| <a name="output_connection_name"></a> [connection\_name](#output\_connection\_name) | Name of the Glue connection |
| <a name="output_crawler_arn"></a> [crawler\_arn](#output\_crawler\_arn) | ARN of the Glue crawler |
| <a name="output_crawler_id"></a> [crawler\_id](#output\_crawler\_id) | ID of the Glue crawler |
| <a name="output_crawler_name"></a> [crawler\_name](#output\_crawler\_name) | Name of the Glue crawler |
| <a name="output_dev_endpoint_arn"></a> [dev\_endpoint\_arn](#output\_dev\_endpoint\_arn) | ARN of the Glue dev endpoint |
| <a name="output_dev_endpoint_id"></a> [dev\_endpoint\_id](#output\_dev\_endpoint\_id) | ID of the Glue dev endpoint |
| <a name="output_dev_endpoint_name"></a> [dev\_endpoint\_name](#output\_dev\_endpoint\_name) | Name of the Glue dev endpoint |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of IAM role |
| <a name="output_job_arn"></a> [job\_arn](#output\_job\_arn) | ARN of the Glue job |
| <a name="output_job_id"></a> [job\_id](#output\_job\_id) | ID of the Glue job |
| <a name="output_job_name"></a> [job\_name](#output\_job\_name) | Name of the Glue job |
| <a name="output_job_script_s3_location"></a> [job\_script\_s3\_location](#output\_job\_script\_s3\_location) | S3 location of the Glue job script |
| <a name="output_registry_arn"></a> [registry\_arn](#output\_registry\_arn) | ARN of the Glue registry |
| <a name="output_registry_name"></a> [registry\_name](#output\_registry\_name) | Name of the Glue registry |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket storing Glue scripts |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | ID of the S3 bucket storing Glue scripts |
| <a name="output_schema_arn"></a> [schema\_arn](#output\_schema\_arn) | ARN of the Glue schema |
| <a name="output_schema_name"></a> [schema\_name](#output\_schema\_name) | Name of the Glue schema |
| <a name="output_security_configuration_id"></a> [security\_configuration\_id](#output\_security\_configuration\_id) | ID of the Glue security configuration |
| <a name="output_security_configuration_name"></a> [security\_configuration\_name](#output\_security\_configuration\_name) | Name of the Glue security configuration |
| <a name="output_trigger_arn"></a> [trigger\_arn](#output\_trigger\_arn) | ARN of the Glue trigger |
| <a name="output_trigger_id"></a> [trigger\_id](#output\_trigger\_id) | ID of the Glue trigger |
| <a name="output_trigger_name"></a> [trigger\_name](#output\_trigger\_name) | Name of the Glue trigger |
| <a name="output_workflow_arn"></a> [workflow\_arn](#output\_workflow\_arn) | ARN of the Glue workflow |
| <a name="output_workflow_id"></a> [workflow\_id](#output\_workflow\_id) | ID of the Glue workflow |
| <a name="output_workflow_name"></a> [workflow\_name](#output\_workflow\_name) | Name of the Glue workflow |
<!-- END_TF_DOCS -->