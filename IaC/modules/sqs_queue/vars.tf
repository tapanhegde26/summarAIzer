variable "queue_name" {}

# Added this new variable
variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket that will send notifications"
}


