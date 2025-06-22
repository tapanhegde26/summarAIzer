resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.role_name}-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.role_name}-${terraform.workspace}-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Log permissions
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:ca-central-1:355366859697:log-group:/aws/lambda/${var.prompt_builder_lambda_function_name}-${terraform.workspace}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = "comprehend:DetectPiiEntities",
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:ca-central-1:355366859697:log-group:/aws/lambda/${var.bedrock_summary_lambda_function_name}-${terraform.workspace}:*"
        ]
      },
      # List transcripts bucket
      {
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = var.s3_transcript_bucket_arn
      },
      # Read objects from transcripts bucket
      {
        Effect   = "Allow",
        Action   = "s3:GetObject",
        Resource = "${var.s3_transcript_bucket_arn}/*"
      },
      # Delete objects from transcripts bucket
      {
        Effect   = "Allow",
        Action   = "s3:DeleteObject",
        Resource = "${var.s3_transcript_bucket_arn}/*"
      },
      # Allow comprehend to write transcripts bucket
      {
        Action = [
          "s3:PutObject",
          "comprehend:DetectPiiEntities"
        ],
        Effect   = "Allow",
        Resource = "${var.s3_transcript_bucket_arn}/*"
      },
      # Allow creating and listing trascripts redacted bucket
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "${var.s3_transcript_redacted_bucket_arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "${var.s3_store_summary_bucket_arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = "s3:GetObject",
        Resource = "${var.s3_prompt_txt_bucket_arn}/*"
      },
      # Call Bedrock
      {
        Effect = "Allow",
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        Resource = var.bedrock_model_arn
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_write" {
  name = "lambda-write-${terraform.workspace}-final-response"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject"],
        Resource = "arn:aws:s3:::s3_store_summary_bucket-*/*"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_publish" {
  name        = "lambda-sns-${terraform.workspace}-publish"
  description = "Allow Lambda to publish to SNS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_publish" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.sns_publish.arn
}
