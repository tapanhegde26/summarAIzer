variable "name" {
  description = "Name of the Step Function"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM Role ARN to be used by Step Function"
  type        = string
}

variable "language_code" {
  description = "Language code for Transcribe (e.g., en-US)"
  type        = string
  default     = "en-US"
}

variable "transcript_bucket" {
  type        = string
  description = "Name of the S3 bucket where transcriptions will be stored"
}

variable "parser_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function that generates prompt and calls Bedrock"
}

variable "prompt_builder_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function that generates prompt and calls Bedrock"
}

variable "summary_generator_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function that generates summary from bedrock"
}