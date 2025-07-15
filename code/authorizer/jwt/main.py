import os
import jwt
from jwt import PyJWKClient

# Load configuration from environment variables
TENANT_ID = os.environ.get("TENANT_ID")
AUDIENCE = os.environ.get("AUDIENCE")

if not TENANT_ID or not AUDIENCE:
    raise Exception("Missing required environment variables: TENANT_ID and AUDIENCE")

ISSUER = f"https://sts.windows.net/{TENANT_ID}/"
JWKS_URL = f"https://login.microsoftonline.com/{TENANT_ID}/discovery/v2.0/keys"

# PyJWT JWKS client (with built-in caching)
_jwk_client = PyJWKClient(JWKS_URL)

def lambda_handler(event, context):
    try:
        token = extract_bearer_token(event["authorizationToken"])
        signing_key = _jwk_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=AUDIENCE,
            issuer=ISSUER
        )

        principal_id = payload["sub"]
        return generate_policy(principal_id, "Allow", event["methodArn"])

    except (Exception) as e:
        print(f"Token validation failed: {e}")
        return generate_policy("anonymous", "Deny", event["methodArn"])


def extract_bearer_token(auth_header):
    if auth_header.lower().startswith("bearer "):
        auth_token = auth_header.split(" ")[1]
    else:
        auth_token = auth_header

    return auth_token


def generate_policy(principal_id, effect, resource):
    return {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resource
                }
            ]
        },
        "context": {
            "user": principal_id
        }
    }
