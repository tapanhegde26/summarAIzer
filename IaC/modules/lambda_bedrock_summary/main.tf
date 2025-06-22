data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/bedrock"
  output_path = "${path.module}/bedrock.zip"
}

resource "aws_lambda_function" "bedrock_summary_lambda" {
  function_name = "${var.function_name}-${terraform.workspace}"
  role          = var.lambda_role_arn
  handler       = "app.handler"
  runtime       = var.runtime
  timeout       = 30

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment_vars
  }
}
