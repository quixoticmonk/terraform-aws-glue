import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Get job parameters
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'database_name', 'table_name', 'output_path'])

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read data from Glue catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database=args['database_name'],
    table_name=args['table_name']
)

# Apply transformations
applymapping = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("column1", "string", "column1", "string"),
        ("column2", "int", "column2", "int"),
        ("column3", "double", "column3", "double")
    ]
)

# Write the result to S3
glueContext.write_dynamic_frame.from_options(
    frame=applymapping,
    connection_type="s3",
    connection_options={"path": args['output_path']},
    format="parquet"
)

# Commit the job
job.commit()
