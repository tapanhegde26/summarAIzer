variable "lambda_function_name" {
  type        = string
  description = "Lambda function name (base, no workspace)"
}

variable "sqs_queue_name" {
  type        = string
  description = "SQS queue name (base, no workspace)"
}

variable "step_function_name" {
  type        = string
  description = "Step function name (base, no workspace)"
}

variable "role_name" {
  type        = string
  description = "Step function name (base, no workspace)"
}