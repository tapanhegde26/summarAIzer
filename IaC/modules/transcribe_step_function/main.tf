resource "aws_sfn_state_machine" "transcribe_state_machine" {
  name     = "${var.name}-${terraform.workspace}"
  role_arn = var.execution_role_arn

  definition = templatefile("${path.module}/step_function_definition.json", {
    transcript_bucket            = "${var.transcript_bucket}"
    parser_lambda_arn            = var.parser_lambda_arn
    prompt_builder_lambda_arn    = var.prompt_builder_lambda_arn
    summary_generator_lambda_arn = var.summary_generator_lambda_arn
  })
}

