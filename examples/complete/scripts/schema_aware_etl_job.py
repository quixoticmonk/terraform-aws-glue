import sys
import json
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, LongType, DoubleType, BooleanType

# Import utility functions
sys.path.append('.')
import utils

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Get job parameters
args = getResolvedOptions(sys.argv, [
    'JOB_NAME', 
    'database_name', 
    'table_name', 
    'output_path',
    'schema_registry_name',
    'schema_name',
    'enable_schema_validation'
])

job.init(args['JOB_NAME'], args)

# Log job start
utils.log_job_start(args['JOB_NAME'])

# Load configuration
config = utils.load_config_from_s3()

# Read data from Glue Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database=args['database_name'],
    table_name=args['table_name'],
    transformation_ctx="datasource"
)

# Convert to DataFrame for easier processing
df = datasource.toDF()

# Apply transformations
df = df.withColumn("processed", F.lit(True))
df = df.withColumn("timestamp", F.current_timestamp().cast(LongType()))

# Validate schema if enabled
if args.get('enable_schema_validation', 'false').lower() == 'true':
    # Define the expected schema based on the schema registry
    expected_schema = StructType([
        StructField("id", StringType(), False),
        StructField("timestamp", LongType(), False),
        StructField("value", DoubleType(), True),
        StructField("category", StringType(), True),
        StructField("processed", BooleanType(), False)
    ])
    
    # Validate DataFrame columns against expected schema
    utils.validate_dataframe_schema(df, expected_schema)
    
    # Log schema validation success
    utils.log_info("Schema validation passed successfully")

# Convert back to DynamicFrame
dynamic_frame = DynamicFrame.fromDF(df, glueContext, "dynamic_frame")

# Write the data to S3 in Parquet format with schema registry information
sink = glueContext.getSink(
    connection_type="s3",
    path=args['output_path'],
    enableUpdateCatalog=True,
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=["category"]
)

# Configure the sink with schema registry information
sink.setFormat("glueparquet")
sink.setCatalogInfo(
    catalogDatabase=args['database_name'],
    catalogTableName=f"{args['table_name']}_processed"
)

# Set additional options for schema registry
sink_options = {
    "useGlueParquetWriter": "true",
    "compression": "snappy"
}

if args.get('schema_registry_name') and args.get('schema_name'):
    sink_options.update({
        "schema.registry.name": args['schema_registry_name'],
        "schema.registry.schema.name": args['schema_name']
    })

sink.writeFrame(dynamic_frame, sink_options)

# Log job completion
utils.log_job_completion(args['JOB_NAME'])
job.commit()
