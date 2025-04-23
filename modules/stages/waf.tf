resource "aws_cloudwatch_log_group" "waf" {
  name = format("aws-waf-logs-%s-%s", var.api_name, var.stage_name)
}

data "aws_iam_policy_document" "waf" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.waf.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${local.region}:${local.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(local.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "waf" {
  policy_document = data.aws_iam_policy_document.waf.json
  policy_name     = "${var.api_name}-${var.stage_name}-logs-policy"
}

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.api_name}-${var.stage_name}"
  description = "Managed WAFv2 ACL for api-gateway ${var.api_name} and stage ${var.stage_name}"
  scope       = "REGIONAL"

  default_action {
    allow {}

    # dynamic "allow" {
    #   for_each = each.value.allow_by_default ? [true] : []

    #   content {
    #     custom_request_handling {
    #       insert_header {
    #         name  = "tf-source"
    #         value = "${var.api_name}-${var.stage_name}"
    #       }
    #     }
    #   }
    # }

    # dynamic "block" {
    #   for_each = each.value.allow_by_default ? [] : [true]

    #   content {}
    # }
  }

  # https://docs.aws.amazon.com/waf/latest/developerguide/monitoring-cloudwatch.html#waf-metrics
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "CountedRequests"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn = aws_wafv2_web_acl.this.arn

  log_destination_configs = [
    aws_cloudwatch_log_group.waf.arn,
  ]
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
