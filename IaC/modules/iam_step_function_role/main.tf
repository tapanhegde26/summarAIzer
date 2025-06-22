resource "aws_iam_role" "step_fn_exec_role" {
  name = "${var.role_name}-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_fn_policy" {
  name = "${var.role_name}-${terraform.workspace}-policy"
  role = aws_iam_role.step_fn_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "transcribe:StartTranscriptionJob",
          "transcribe:GetTranscriptionJob",
          "transcribe:GetCallAnalyticsJob",
          "transcribe:StartCallAnalyticsJob"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = "${var.output_bucket_arn}/*"
      },
      {
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : "${var.upload_bucket_arn}/*"
      },
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "logs:*"
        ],
        "Resource" : "*"
      },
      {
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : "${var.step_function_parser_lambda_arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "${var.prompt_builder_lambda_arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "${var.bedrock_summary_lambda_arn}"
      }
    ]
  })
}
