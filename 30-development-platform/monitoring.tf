resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  provider            = aws.dev
  alarm_name          = "${local.name_prefix}-alb-5xx"
  alarm_description   = "ALB is returning 5XX errors."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  provider            = aws.dev
  alarm_name          = "${local.name_prefix}-lambda-errors"
  alarm_description   = "Lambda function is reporting errors."
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }
}