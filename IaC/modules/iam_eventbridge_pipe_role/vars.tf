variable "role_name" {
  description = "Base name of the IAM role"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the source SQS queue"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the target Lambda function"
  type        = string
}

variable "pipe_name" {
  description = "Name of the EventBridge pipe (used for logging)"
  type        = string
}
