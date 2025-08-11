locals {
  authorizer = {
    lambda_arn            = module.ping.lambda_function_invoke_arn
    identity_source       = "method.request.header.authToken"
    result_ttl_in_seconds = 300
    type                  = "TOKEN"
  }

  api = {
    "document_read" = {
      authorized  = false
      http_method = "GET"
      resource    = "documents"
    }

    "document_create" = {
      authorized  = true
      http_method = "POST"
      resource    = "documents"
    }
  }
}
