"""
Utility functions for AWS Glue jobs
"""

import json
import boto3
from datetime import datetime

def read_config(config_path):
    """
    Read configuration from a JSON file in S3
    """
    s3_client = boto3.client('s3')
    bucket, key = config_path.replace('s3://', '').split('/', 1)
    response = s3_client.get_object(Bucket=bucket, Key=key)
    content = response['Body'].read().decode('utf-8')
    return json.loads(content)

def log_job_status(job_name, status, message=None):
    """
    Log job status to CloudWatch
    """
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_message = f"[{timestamp}] Job {job_name} - Status: {status}"
    if message:
        log_message += f" - {message}"
    print(log_message)
    return log_message

def validate_data_frame(df, required_columns):
    """
    Validate that a DataFrame contains required columns
    """
    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")
    return True
