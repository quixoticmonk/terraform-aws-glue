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
  
  # Worker configuration
  worker_type = "G.1X"
  number_of_workers = 2
  
  # Encryption configuration
  enable_s3_encryption = true
  s3_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  
  enable_job_bookmarks_encryption = true
  job_bookmarks_encryption_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  
  enable_cloudwatch_encryption = true
  cloudwatch_encryption_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  
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

### AWSCC Provider Resources
- AWSCC Glue Schema
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
- **GlueETL (`glueetl`)**: For Spark-based ETL jobs
- **PythonShell (`pythonshell`)**: For lightweight Python scripts

#### Glue Versions
- **Glue 3.0**: Based on Apache Spark 3.1.1, Python 3.7
- **Glue 4.0**: Based on Apache Spark 3.3.0, Python 3.10
- **Glue 5.0**: Based on Apache Spark 3.4.1, Python 3.10

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
  
  create_job = true
  job_name   = "example-job"
  job_command_script_location = "s3://my-existing-bucket/scripts/my-job.py"
}
```

#### 2. Local Script Upload
Provide a local script from your repository that will be uploaded to S3:

```hcl
module "glue" {
  source = "terraform-aws-modules/glue/aws"

  # ... other configuration ...
  
  create_job = true
  job_name   = "example-job"
  
  # Option 1: Create a new S3 bucket for scripts
  create_s3_bucket = true
  s3_bucket_name   = "my-glue-scripts-bucket" # Optional, generated if not provided
  
  # Option 2: Use an existing S3 bucket
  create_s3_bucket      = false
  existing_s3_bucket_name = "my-existing-bucket"
  
  # Local script path and optional S3 key
  job_script_local_path = "${path.module}/scripts/my-job.py"
  job_script_s3_key     = "custom/path/my-job.py" # Optional, defaults to scripts/filename
}
```

This approach automatically:
1. Creates an S3 bucket if requested
2. Uploads your local script to the specified S3 bucket
3. Sets the correct S3 path in the Glue job configuration
4. Tracks script changes using file checksums for proper updates

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.42.0 |
| awscc | >= 0.70.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.42.0 |
| awscc | >= 0.70.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create | Controls if resources should be created (affects all resources) | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| prefix | Prefix to be used for all resources | `string` | `""` | no |
| create_iam_role | Controls if IAM role should be created | `bool` | `true` | no |
| iam_role_arn | Existing IAM role ARN for the Glue resources | `string` | `""` | no |
| create_catalog_database | Controls if Glue catalog database should be created | `bool` | `true` | no |
| create_connection | Controls if Glue connection should be created | `bool` | `true` | no |
| create_crawler | Controls if Glue crawler should be created | `bool` | `true` | no |
| create_job | Controls if Glue job should be created | `bool` | `true` | no |
| create_trigger | Controls if Glue trigger should be created | `bool` | `true` | no |
| create_workflow | Controls if Glue workflow should be created | `bool` | `true` | no |
| create_security_configuration | Controls if Glue security configuration should be created | `bool` | `true` | no |
| create_dev_endpoint | Controls if Glue dev endpoint should be created | `bool` | `true` | no |
| create_schema | Controls if Glue schema should be created | `bool` | `true` | no |
| create_registry | Controls if Glue registry should be created | `bool` | `true` | no |

For a complete list of inputs, see the [variables.tf](variables.tf) file.

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | ARN of IAM role |
| iam_role_name | Name of IAM role |
| catalog_database_id | ID of the Glue catalog database |
| catalog_database_name | Name of the Glue catalog database |
| catalog_database_arn | ARN of the Glue catalog database |
| connection_id | ID of the Glue connection |
| connection_name | Name of the Glue connection |
| crawler_id | ID of the Glue crawler |
| crawler_name | Name of the Glue crawler |
| crawler_arn | ARN of the Glue crawler |
| job_id | ID of the Glue job |
| job_name | Name of the Glue job |
| job_arn | ARN of the Glue job |
| trigger_id | ID of the Glue trigger |
| trigger_name | Name of the Glue trigger |
| trigger_arn | ARN of the Glue trigger |
| workflow_id | ID of the Glue workflow |
| workflow_name | Name of the Glue workflow |
| workflow_arn | ARN of the Glue workflow |
| security_configuration_id | ID of the Glue security configuration |
| security_configuration_name | Name of the Glue security configuration |
| dev_endpoint_id | ID of the Glue dev endpoint |
| dev_endpoint_name | Name of the Glue dev endpoint |
| dev_endpoint_arn | ARN of the Glue dev endpoint |
| schema_arn | ARN of the Glue schema |
| schema_name | Name of the Glue schema |
| registry_arn | ARN of the Glue registry |
| registry_name | Name of the Glue registry |

## License

Apache-2.0 License. See [LICENSE](LICENSE) for full details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.42.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | 1.38.0 |
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
| [aws_glue_security_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) | resource |
| [aws_glue_trigger.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger) | resource |
| [aws_glue_workflow.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_workflow) | resource |
| [aws_iam_policy.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.glue_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.glue_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.glue_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_object.additional_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.glue_script](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.python_dependencies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [awscc_glue_registry.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/glue_registry) | resource |
| [awscc_glue_schema.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/glue_schema) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.glue_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.glue_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_script_files"></a> [additional\_script\_files](#input\_additional\_script\_files) | Map of additional script files to upload to S3. The key is the S3 object key and the value is the local file path | `map(string)` | `{}` | no |
| <a name="input_catalog_database_name"></a> [catalog\_database\_name](#input\_catalog\_database\_name) | Name of the Glue catalog database | `string` | `null` | no |
| <a name="input_crawler_name"></a> [crawler\_name](#input\_crawler\_name) | Name of the Glue crawler | `string` | `null` | no |
| <a name="input_crawler_s3_targets"></a> [crawler\_s3\_targets](#input\_crawler\_s3\_targets) | List of S3 targets for the crawler | `list(map(string))` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_catalog_database"></a> [create\_catalog\_database](#input\_create\_catalog\_database) | Controls if Glue catalog database should be created | `bool` | `false` | no |
| <a name="input_create_crawler"></a> [create\_crawler](#input\_create\_crawler) | Controls if Glue crawler should be created | `bool` | `false` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Controls if IAM role should be created | `bool` | `true` | no |
| <a name="input_create_job"></a> [create\_job](#input\_create\_job) | Controls if Glue job should be created | `bool` | `false` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Controls if S3 bucket should be created for Glue scripts | `bool` | `false` | no |
| <a name="input_enable_job_insights"></a> [enable\_job\_insights](#input\_enable\_job\_insights) | Specifies whether job insights are enabled for the job | `bool` | `false` | no |
| <a name="input_existing_s3_bucket_name"></a> [existing\_s3\_bucket\_name](#input\_existing\_s3\_bucket\_name) | Name of an existing S3 bucket to store Glue scripts. Used when create\_s3\_bucket is false | `string` | `null` | no |
| <a name="input_glue_version"></a> [glue\_version](#input\_glue\_version) | The version of Glue to use | `string` | `"4.0"` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the Glue resources | `string` | `""` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role for Glue resources | `string` | `null` | no |
| <a name="input_job_command_script_location"></a> [job\_command\_script\_location](#input\_job\_command\_script\_location) | S3 location of the script to be executed. Only used if job\_script\_local\_path is not provided | `string` | `null` | no |
| <a name="input_job_connections"></a> [job\_connections](#input\_job\_connections) | List of connections to use for the job | `list(string)` | `[]` | no |
| <a name="input_job_default_arguments"></a> [job\_default\_arguments](#input\_job\_default\_arguments) | Default arguments for the job | `map(string)` | `{}` | no |
| <a name="input_job_description"></a> [job\_description](#input\_job\_description) | Description of the Glue job | `string` | `null` | no |
| <a name="input_job_execution_class"></a> [job\_execution\_class](#input\_job\_execution\_class) | Indicates whether the job is run with a standard or flexible execution class | `string` | `"STANDARD"` | no |
| <a name="input_job_language"></a> [job\_language](#input\_job\_language) | The script programming language. Valid values: scala, python | `string` | `"python"` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | Name of the Glue job | `string` | `null` | no |
| <a name="input_job_script_local_path"></a> [job\_script\_local\_path](#input\_job\_script\_local\_path) | Local path to the Glue job script in the repository | `string` | `null` | no |
| <a name="input_job_script_s3_key"></a> [job\_script\_s3\_key](#input\_job\_script\_s3\_key) | S3 key where the job script will be uploaded. If not provided, the filename from job\_script\_local\_path will be used | `string` | `null` | no |
| <a name="input_job_type"></a> [job\_type](#input\_job\_type) | The type of job. Valid values are: 'glueetl' or 'pythonshell' | `string` | `"glueetl"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum capacity for this job. Used only for Glue ETL jobs | `number` | `null` | no |
| <a name="input_max_concurrent_runs"></a> [max\_concurrent\_runs](#input\_max\_concurrent\_runs) | The maximum number of concurrent runs allowed for this job | `number` | `1` | no |
| <a name="input_number_of_workers"></a> [number\_of\_workers](#input\_number\_of\_workers) | The number of workers to use for the job | `number` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be used for all resources | `string` | `""` | no |
| <a name="input_python_dependencies_local_path"></a> [python\_dependencies\_local\_path](#input\_python\_dependencies\_local\_path) | Local path to a zip file containing Python dependencies for the job | `string` | `null` | no |
| <a name="input_python_dependencies_s3_key"></a> [python\_dependencies\_s3\_key](#input\_python\_dependencies\_s3\_key) | S3 key where the Python dependencies zip will be uploaded | `string` | `"dependencies/python_modules.zip"` | no |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | The Python version to use. If not specified, it will be determined based on Glue version | `string` | `null` | no |
| <a name="input_s3_bucket_force_destroy"></a> [s3\_bucket\_force\_destroy](#input\_s3\_bucket\_force\_destroy) | Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed | `bool` | `false` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket to store Glue scripts. If not provided and create\_s3\_bucket is true, a name will be generated | `string` | `null` | no |
| <a name="input_s3_bucket_tags"></a> [s3\_bucket\_tags](#input\_s3\_bucket\_tags) | A map of tags to assign to the S3 bucket | `map(string)` | `{}` | no |
| <a name="input_security_configuration"></a> [security\_configuration](#input\_security\_configuration) | The name of the Security Configuration to be associated with the job | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The job timeout in minutes | `number` | `2880` | no |
| <a name="input_worker_type"></a> [worker\_type](#input\_worker\_type) | The type of worker to use. Valid values: Standard, G.1X, G.2X, G.4X, G.8X, G.025X | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of IAM role |
| <a name="output_job_arn"></a> [job\_arn](#output\_job\_arn) | ARN of the Glue job |
| <a name="output_job_id"></a> [job\_id](#output\_job\_id) | ID of the Glue job |
| <a name="output_job_name"></a> [job\_name](#output\_job\_name) | Name of the Glue job |
| <a name="output_job_script_s3_location"></a> [job\_script\_s3\_location](#output\_job\_script\_s3\_location) | S3 location of the Glue job script |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket storing Glue scripts |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | ID of the S3 bucket storing Glue scripts |
<!-- END_TF_DOCS -->