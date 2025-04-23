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
 
## Test an API Gateway lambda authorizer from CLI

```
API_ID=ixya3v4yaj

: Test request authorizer
AUTH_ID=ok9mfq
aws apigateway test-invoke-authorizer \
   --rest-api-id $API_ID \
   --authorizer-id $AUTH_ID \
   --headers HeaderAuth1=headerValue1 \
   --path-with-query-string "/?QueryString1=queryValue1" \
   --stage-variables StageVar1=stageValue1 | jq .

: Test token authorizer
AUTH_ID=0cxiiy
aws apigateway test-invoke-authorizer \
   --rest-api-id $API_ID \
   --authorizer-id $AUTH_ID \
   --headers authToken=allow
```

# Test API Gateway

```
curl -XPOST -H "authToken: alloww" https://agc-c0f4.dev.cpa-devops.aws.clarivate.net/dev/documents -d '{"name":"pepe"}'
```

# Terraform module

This module only supports HTTP and websockets based APIs.

https://registry.terraform.io/modules/terraform-aws-modules/apigateway-v2/aws/latest
