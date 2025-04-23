import boto3
import json
import os
import time
import uuid

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    body = json.loads(event.get('body'))

    try:
        # Generate a unique UUID for the new entry
        item_uuid = str(uuid.uuid4())
        
        # Parse the request body
        name = body['name']
        
        # Get the current Unix timestamp
        timestamp = str(time.time())

        # Add the new item to the DynamoDB table
        item = {
            'uuid': item_uuid,  
            'name': name,
            'timestamp': timestamp
        }
        table.put_item(Item=item)
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Item added successfully', 'item': item})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    