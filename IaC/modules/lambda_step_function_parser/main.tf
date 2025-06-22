data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/step_function_parser"
  output_path = "${path.module}/step_function_parser.zip"
}

resource "aws_lambda_function" "step_func_parser_lambda" {
  function_name = "${var.function_name}-${terraform.workspace}"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.runtime
  timeout       = 30

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment_vars
  }
}
