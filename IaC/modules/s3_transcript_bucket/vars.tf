variable "bucket_name" {
  description = "Name of the transcript S3 bucket"
  type        = string
}

variable "lambda_arn" {
  description = "ARN of Lambda to trigger on new transcript"
}

