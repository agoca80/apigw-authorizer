import boto3
import os
import json

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Scan the DynamoDB table to retrieve all items
        response = table.scan()
        items = response.get('Items', [])
        print(items)
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Items retrieved successfully', 'items': items})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
