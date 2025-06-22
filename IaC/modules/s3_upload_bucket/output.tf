output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

#added this line
output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}