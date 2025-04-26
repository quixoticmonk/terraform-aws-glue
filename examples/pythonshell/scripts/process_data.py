import sys
import boto3
import pandas as pd
from awsglue.utils import getResolvedOptions

# Get job parameters
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'input_path', 'output_path'])

def main():
    """
    Simple PythonShell job that processes data using pandas
    """
    print(f"Starting {args['JOB_NAME']}")
    
    # Parse S3 paths
    input_path = args['input_path']
    output_path = args['output_path']
    
    print(f"Reading data from {input_path}")
    
    # Initialize S3 client
    s3 = boto3.client('s3')
    
    # Example: List files in input path
    bucket, prefix = input_path.replace('s3://', '').split('/', 1)
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    
    # Process each file
    for obj in response.get('Contents', []):
        key = obj['Key']
        print(f"Processing file: {key}")
        
        # Example: Read CSV file from S3
        obj = s3.get_object(Bucket=bucket, Key=key)
        df = pd.read_csv(obj['Body'])
        
        # Example: Simple transformation
        if not df.empty:
            # Add a new column
            df['processed'] = True
            df['timestamp'] = pd.Timestamp.now().isoformat()
            
            # Save the processed data
            output_key = f"{prefix}processed_{key.split('/')[-1]}"
            output_buffer = df.to_csv(index=False)
            
            # Write to S3
            output_bucket = output_path.replace('s3://', '').split('/', 1)[0]
            output_key = output_path.replace(f's3://{output_bucket}/', '') + f"processed_{key.split('/')[-1]}"
            
            s3.put_object(
                Body=output_buffer,
                Bucket=output_bucket,
                Key=output_key
            )
            
            print(f"Saved processed file to s3://{output_bucket}/{output_key}")
    
    print(f"Job {args['JOB_NAME']} completed successfully")

if __name__ == "__main__":
    main()
