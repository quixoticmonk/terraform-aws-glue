import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Simple transformation
df = spark.createDataFrame(
    [("John", 30), ("Alice", 25), ("Bob", 35)],
    ["name", "age"]
)

# Show the data
df.show()

# Job completed
job.commit()
