output "s3_bucket_name" {
  value = module.s3_upload_bucket.bucket_name
}

output "sqs_queue_url" {
  value = module.sqs_queue.queue_url
}

output "eventbridge_pipe_name" {
  value = module.event_bridge_pipe.pipe_name
}
