data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/function.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  provider          = aws.dev
  name              = "/aws/lambda/${local.name_prefix}-function"
  retention_in_days = 90
}

resource "aws_lambda_function" "this" {
  provider         = aws.dev
  function_name    = "${local.name_prefix}-function"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda.arn
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      ENVIRONMENT = "dev"
      APPLICATION = var.application_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  provider            = aws.dev
  name                = "${local.name_prefix}-schedule"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  provider = aws.dev
  rule     = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn      = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "eventbridge" {
  provider      = aws.dev
  statement_id   = "AllowEventBridgeInvoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.this.function_name
  principal      = "events.amazonaws.com"
  source_arn     = aws_cloudwatch_event_rule.schedule.arn
}