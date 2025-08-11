# API Gateway links

- https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-deploy-api.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/private-api-tutorial.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-basic-concept.html

# Lambda authorizers

- https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html

# API Gateway REST API

- https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-rest-api.html
- https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-http.html

# SAML authentication

- https://repost.aws/questions/QU1Mc0g0X6RR-qJ93SUL8Dqw/implementing-saml-based-login-and-api-authorization-with-api-gateway-lambda-authorizer-and-microsoft-idp
- https://repost.aws/knowledge-center/cognito-third-party-saml-idp
- https://aws.amazon.com/blogs/modernizing-with-aws/secure-api-authorization-in-amazon-api-gateway-using-microsoft-entra-id/

# Notes
 
API Gateway uses Java pattern-style regexes for response mapping. For more information, see Pattern in the Oracle documentation.
 
Every time you update an API, you must redeploy the API to an existing stage or to a new stage. Updating an API includes modifying routes, methods, integrations, authorizers, resource policies, and anything else other than stage settings.
 
Using the API's default domain name, the base URL of a REST API (for example) in a given stage ({stageName}) is in the following format:
https://{restapi-id}.execute-api.{region}.amazonaws.com/{stageName}
To make the API's default base URL more user-friendly, you can create a custom domain name (for example, api.example.com) to replace the default hostname of the API. To support multiple APIs under the custom domain name, you must map an API stage to a base path.
 
With a custom domain name of {api.example.com} and the API stage mapped to a base path of ({basePath}) under the custom domain name, the base URL of a REST API becomes the following:
https://{api.example.com}/{basePath}
 
A stage is a named reference to a deployment, which is a snapshot of the API. You use a Stage to manage and optimize a particular deployment. For example, you can configure stage settings to enable caching, customize request throttling, configure logging, define stage variables, or attach a canary release for testing. The following section shows how to create and configure your stage.
 
https://docs.aws.amazon.com/apigateway/latest/developerguide/aws-api-gateway-stage-variables-reference.html
https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html


# Authorizer dependencies

The lambda authorizer has dependencies that are downloaded in local by terraform before uploading the lambda code to AWS. To achieve this, the lambda module runs pip in local. Because of this, you must ensure pip will download the dependencies for the lambda environment, and not for the local environment. This happens when you run terraform in an Apple Silicon platform, but the lambda runs in a Graviton (AWS ARM) platform. An easy way to achieve this is by confgirung the following environment variables before running the terraform commands:

```
export PIP_ONLY_BINARY=:all:
export PIP_PLATFORM=manylinux2014_aarch64
```

This will instruct pip which versions should download before packing and uploading them to the lambda service.

Reference link: https://repost.aws/knowledge-center/lambda-python-package-compatible

# Get a JWT token from Microsoft Entra ID

```
CLIENT_SECRET=$(cat venv/secret)
CLIENT_ID=3e5d5615-9af4-446a-816b-95676db5ce36
TENANT_ID=b2c9c85a-71f3-48a1-8311-e106f47ff3f8
AUDIENCE=api://97a9f0a2-9ef0-4088-9b76-f7144813e6e3

TOKEN=$(
  curl -sXPOST https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "scope=$AUDIENCE/.default" \
    -d "grant_type=client_credentials" |
  jq -r .access_token
)

echo $TOKEN | jq -R 'split(".") | .[0],.[1] | @base64d | fromjson'
```

## Test token lambda authorizer from CLI

```
API_ID=$(terraform output -raw api_id)
AUTH_ID=$(terraform output -raw authorizer_id)

TEST=$(
  aws apigateway test-invoke-authorizer \
    --rest-api-id $API_ID \
    --authorizer-id $AUTH_ID \
    --headers authToken="$TOKEN"
)

echo $TEST
echo $TEST | jq '.policy|fromjson'
```

# Test API Gateway

```
reset
DATA='{"name":"foo"}'
AUTH="token: $TOKEN"
ENDPOINT=https://agc-ping.dev.cpa-devops.aws.clarivate.net/document
curl -sXGET  $ENDPOINT                   | jq '.items|length'
curl -sXPOST $ENDPOINT -d $DATA          | jq .
curl -sXGET  $ENDPOINT                   | jq '.items|length'
curl -sXPOST $ENDPOINT -d $DATA -H $AUTH | jq .
curl -sXGET  $ENDPOINT                   | jq '.items|length'
```

# Ping federate

```
IPP_URL=...
CLIENT_ID=...
CLIENT_SECRET=...
GRANT_TYPE=urn:pingidentity.com:oauth2:grant_type:validate_bearer

source venv/variables

TOKEN=$(
    curl -X POST "$IPP_URL" \
        -u "$CLIENT_ID:$CLIENT_SECRET" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials" \
        -d "scope=api_client" |
    jq -r .access_token
)

echo $TOKEN

curl -sXPOST "$IPP_URL" \
  -u "$CLIENT_ID:$CLIENT_SECRET" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=$GRANT_TYPE" \
  -d "token=$TOKEN"

aws logs tail /aws/lambda/agc-c0f4-ping --follow &

API_ID=$(terraform output -raw api_id)
AUTH_ID=$(terraform output -raw authorizer_id)
HOSTNAME=$(terraform output -raw api_domain_name)

TEST=$(
  aws apigateway test-invoke-authorizer \
    --rest-api-id $API_ID \
    --authorizer-id $AUTH_ID \
    --headers authToken="$TOKEN"
)

echo $TEST

echo $TEST | jq '.policy|fromjson'

reset
DATA='{"name":"foo"}'
ENDPOINT=https://$HOSTNAME/documents
curl -sXGET  $ENDPOINT
curl -sXGET  $ENDPOINT                       | jq '.items|length'
curl -sXPOST $ENDPOINT -d "$DATA"            | jq .
curl -sXGET  $ENDPOINT                       | jq '.items|length'
curl -sXPOST $ENDPOINT -d "$DATA" -H "authToken: $TOKEN" | jq .
curl -sXGET  $ENDPOINT                       | jq '.items|length'

```
