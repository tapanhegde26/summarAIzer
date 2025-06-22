variable "pipe_name" {
  description = "Name of the EventBridge Pipe"
  type        = string
}

variable "pipe_role_arn" {
  description = "IAM role ARN for EventBridge Pipe"
  type        = string
}

variable "source_arn" {
  description = "ARN of the source SQS queue"
  type        = string
}

variable "target_arn" {
  description = "ARN of the target service (Transcribe Step Function or Lambda)"
  type        = string
}

variable "batch_size" {
  description = "Number of messages to include in a batch"
  type        = number
  default     = 1
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "dev"
}
