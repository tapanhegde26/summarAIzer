resource "aws_iam_role" "step_func_parser_lambda_exec_role" {
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
  name = "step_function_parser_policy-${terraform.workspace}"
  role = aws_iam_role.step_func_parser_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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
          "arn:aws:logs:ca-central-1:355366859697:log-group:/aws/lambda/${var.lambda_function_name}-${terraform.workspace}:*"
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
          "arn:aws:logs:ca-central-1:355366859697:log-group:/aws/lambda/${var.lambda_function_name}-${terraform.workspace}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = "arn:aws:sqs:ca-central-1:355366859697:${var.sqs_queue_name}-${terraform.workspace}"
      },
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = "arn:aws:states:ca-central-1:355366859697:stateMachine:${var.step_function_name}-${terraform.workspace}"
      }
    ]
  })
}