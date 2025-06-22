variable "role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
}

variable "s3_transcript_bucket_arn" {
  description = "ARN of the transcript S3 bucket"
  type        = string
}

variable "s3_transcript_redacted_bucket_arn" {
  description = "ARN of the transcript redacted S3 bucket"
  type        = string
}

variable "bedrock_model_arn" {
  description = "ARN of the Bedrock model (Claude, Titan, etc)"
  type        = string
}

variable "s3_store_summary_bucket_arn" {
  description = "ARN of the store summary S3 bucket"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "prompt_builder_lambda_function_name" {
  description = "prompt builder lambda"
  type        = string
}

variable "bedrock_summary_lambda_function_name" {
  description = "bedrock summary lambda"
  type        = string
}

variable "s3_prompt_txt_bucket_arn" {
  description = "ARN of the prompt txt S3 bucket"
  type        = string
}
