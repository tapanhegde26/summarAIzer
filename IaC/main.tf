terraform {
  backend "s3" {
    bucket         = "coconut-tf-state"
    key            = "terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "coconut-tf-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_upload_bucket" {
  source        = "./modules/s3_upload_bucket"
  bucket_name   = "coconut-upload-recordings-bucket-${terraform.workspace}"
  sqs_queue_arn = module.sqs_queue.queue_arn
}

module "sqs_queue" {
  source        = "./modules/sqs_queue"
  queue_name    = "coconut-sqs-queue-${terraform.workspace}"
  s3_bucket_arn = module.s3_upload_bucket.bucket_arn
}

module "iam_eventbridge_pipe_role" {
  source              = "./modules/iam_eventbridge_pipe_role"
  role_name           = "event-bridge-pipe-role"
  pipe_name           = module.event_bridge_pipe.pipe_name
  sqs_queue_arn       = module.sqs_queue.queue_arn
  lambda_function_arn = module.lambda_step_function_parser.lambda_arn
  #target_actions      = ["states:StartExecution"]
}

module "event_bridge_pipe" {
  source        = "./modules/event_bridge_pipe"
  pipe_name     = "coconut-eventbridge-pipe-${terraform.workspace}"
  source_arn    = module.sqs_queue.queue_arn
  target_arn    = module.transcribe_step_function.state_machine_arn
  pipe_role_arn = module.iam_eventbridge_pipe_role.role_arn
}

module "lambda_step_function_parser" {
  source          = "./modules/lambda_step_function_parser"
  function_name   = "step_function_parser"
  lambda_role_arn = module.iam_lambda_step_func_parser.role_arn
  lambda_zip_path = "${path.module}/step_function_parser.zip"
}

module "iam_step_function_role" {
  source                          = "./modules/iam_step_function_role"
  role_name                       = "stepfn-transcribe-exec"
  output_bucket_arn               = module.s3_transcript_bucket.bucket_arn
  upload_bucket_arn               = module.s3_upload_bucket.bucket_arn
  step_function_parser_lambda_arn = module.lambda_step_function_parser.lambda_arn
  prompt_builder_lambda_arn       = module.lambda_prompt_builder.lambda_arn
  bedrock_summary_lambda_arn      = module.lambda_bedrock_summary.lambda_arn
}

module "transcribe_step_function" {
  source                       = "./modules/transcribe_step_function"
  name                         = "transcribe-job-workflow"
  execution_role_arn           = module.iam_step_function_role.role_arn
  transcript_bucket            = module.s3_transcript_bucket.bucket_name
  parser_lambda_arn            = module.lambda_step_function_parser.lambda_arn
  prompt_builder_lambda_arn    = module.lambda_prompt_builder.lambda_arn
  summary_generator_lambda_arn = module.lambda_bedrock_summary.lambda_arn
}

module "s3_transcript_bucket" {
  source      = "./modules/s3_transcript_bucket"
  bucket_name = "coconut-transcript-output-bucket-${terraform.workspace}"
  lambda_arn  = module.lambda_prompt_builder.lambda_arn
}

module "s3_transcript_redacted_bucket" {
  source      = "./modules/s3_transcript_redacted_bucket"
  bucket_name = "coconut-transcript-redacted-bucket-${terraform.workspace}"
  lambda_arn  = module.lambda_prompt_builder.lambda_arn
}

module "s3_prompt_txt_bucket" {
  source      = "./modules/s3_prompt_txt_bucket"
  bucket_name = "coconut-prompt-txt-bucket-${terraform.workspace}"
}

module "lambda_prompt_builder" {
  source          = "./modules/lambda_prompt_builder"
  function_name   = "prompt-builder-lambda"
  lambda_role_arn = module.iam_lambda_exec_role.role_arn
  lambda_zip_path = "${path.module}/prompt_builder.zip"
  environment_vars = {
    PROMPT_BUCKET   = module.s3_prompt_txt_bucket.bucket_name
    PROMPT_KEY      = "system_prompt.txt"
    REDACTED_BUCKET = module.s3_transcript_redacted_bucket.bucket_name
  }
}

module "lambda_bedrock_summary" {
  source          = "./modules/lambda_bedrock_summary"
  function_name   = "bedrock-summary-lambda"
  lambda_role_arn = module.iam_lambda_exec_role.role_arn
  lambda_zip_path = "${path.module}/bedrock.zip"
  environment_vars = {
    BEDROCK_MODEL_ID = "anthropic.claude-3-haiku-20240307-v1:0"
    OUTPUT_BUCKET    = module.s3_store_summary_bucket.bucket_name
    SNS_TOPIC_ARN    = module.sns.topic_arn

  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_prompt_builder.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_transcript_bucket.bucket_arn
}

module "iam_lambda_exec_role" {
  source                               = "./modules/iam_lambda_exec_role"
  role_name                            = "lambda-bedrock-exec-role"
  s3_transcript_bucket_arn             = module.s3_transcript_bucket.bucket_arn
  s3_transcript_redacted_bucket_arn    = module.s3_transcript_redacted_bucket.bucket_arn
  s3_store_summary_bucket_arn          = module.s3_store_summary_bucket.bucket_arn
  bedrock_model_arn                    = "arn:aws:bedrock:ca-central-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
  sns_topic_arn                        = module.sns.topic_arn
  prompt_builder_lambda_function_name  = "prompt-builder-lambda"
  bedrock_summary_lambda_function_name = "bedrock-summary-lambda"
  s3_prompt_txt_bucket_arn             = module.s3_prompt_txt_bucket.bucket_arn
}

module "iam_lambda_step_func_parser" {
  source               = "./modules/iam_lambda_step_func_parser"
  role_name            = "step-func-parser-exec-${terraform.workspace}-role"
  lambda_function_name = module.lambda_step_function_parser.lambda_arn
  sqs_queue_name       = "coconut-sqs-queue-${terraform.workspace}"
  step_function_name   = "transcribe-job-workflow"

}

module "s3_store_summary_bucket" {
  source      = "./modules/s3_store_summary_bucket"
  bucket_name = "coconut-store-summary-bucket"
}

module "sns" {
  source     = "./modules/sns_topic"
  topic_name = "bedrock-summary-${terraform.workspace}-topic"
}

resource "aws_lambda_permission" "allow_sns_publish" {
  statement_id  = "AllowExecutionFromLambda"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_prompt_builder.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns.topic_arn
}
