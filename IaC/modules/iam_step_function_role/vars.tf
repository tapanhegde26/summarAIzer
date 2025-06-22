variable "role_name" {}
variable "output_bucket_arn" {}
variable "upload_bucket_arn" {}
variable "step_function_parser_lambda_arn" {}
variable "prompt_builder_lambda_arn" {
  description = "ARN of the prompt builder Lambda"
  type        = string
}
variable "bedrock_summary_lambda_arn" {
  description = "ARN of the get summary from bedrock"
  type        = string
}