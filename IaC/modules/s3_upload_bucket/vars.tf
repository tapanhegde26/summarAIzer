variable "bucket_name" {}
variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue for notifications"
  type        = string
}
