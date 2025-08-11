import os
import requests

from requests.auth import HTTPBasicAuth

AUTH_URL = os.environ.get("PING_URL")
CLIENT_ID = os.environ.get("PING_CLIENT_ID")
CLIENT_SECRET = os.environ.get("PING_CLIENT_SECRET")


# The User-Agent is compulsory! Otherwise the ping-federate endpoint will
# return a 403 Forbidden without any further details
def check_token(token):
    auth = HTTPBasicAuth(CLIENT_ID, CLIENT_SECRET)
    headers = {
        'User-Agent': 'AmazonAPIGateway',
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    data = {
        "token": token,
        "grant_type": "urn:pingidentity.com:oauth2:grant_type:validate_bearer"
    }

    response = requests.post(AUTH_URL, data=data, auth=auth, headers=headers)
    return response.json()


def lambda_handler(event, context):
    try:
        token = event.get('authorizationToken')
        result = check_token(token)
        expires_in = result.get('expires_in')
        if expires_in == None:
            effect = 'Deny'
        elif expires_in > 0:
            effect = 'Allow'
        else:
            effect = 'Deny'
    except Exception as e:
        print(f"Error during token introspection: {e}")
        effect = 'Deny'

    return generate_policy('user', effect, event['methodArn'])


def generate_policy(principal_id, effect, resource):
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
    }
