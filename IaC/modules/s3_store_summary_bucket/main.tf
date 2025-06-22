resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${terraform.workspace}"
  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-public-access-block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#resource "aws_s3_bucket_lifecycle_configuration" "bucket-configuration" {
#  bucket = aws_s3_bucket.bucket.id

# rule {
#    id     = "expire-temp-files-${terraform.workspace}"
#    status = "Enabled"

#    expiration {
#      days = 30
#    }

#    filter {
#      prefix = "temp/"
#    }
#  }
# Added this line dependency on versioning
#  depends_on = [aws_s3_bucket_versioning.bucket-versioning]

#}
