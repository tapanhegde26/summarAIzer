resource "aws_s3_bucket" "transcript_redacted_bucket" {
  bucket = var.bucket_name
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3-${var.bucket_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.transcript_redacted_bucket.arn
}


resource "aws_s3_bucket_policy" "allow_transcribe_write_access" {
  bucket = aws_s3_bucket.transcript_redacted_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "AllowTranscribeToWriteOutputFiles",
        "Effect" : "Allow",
        Principal = {
          Service = "transcribe.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}