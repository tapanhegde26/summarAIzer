resource "aws_iam_role" "pipe_role" {
  name = "${var.role_name}-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "pipes.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "custom_sqs_policy" {
  name        = "custom-sqs-policy-${terraform.workspace}"
  description = "Custom policy for SQS access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = [
          var.sqs_queue_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_sqs_policy" {
  role       = aws_iam_role.pipe_role.name
  policy_arn = aws_iam_policy.custom_sqs_policy.arn
}

resource "aws_iam_policy" "custom_stepfunctions_policy" {
  name        = "custom-stepfunctions-policy-${terraform.workspace}"
  description = "Allows starting execution of a specific Step Function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "states:StartExecution"
        ],
        Resource = [
          "arn:aws:states:ca-central-1:355366859697:stateMachine:transcribe-job-workflow-${terraform.workspace}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_stepfunctions_custom_policy" {
  role       = aws_iam_role.pipe_role.name
  policy_arn = aws_iam_policy.custom_stepfunctions_policy.arn
}


resource "aws_iam_role_policy" "pipe_policy" {
  name = "${var.role_name}-${terraform.workspace}-policy"
  role = aws_iam_role.pipe_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "SQSAccess",
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = var.sqs_queue_arn
      },
      {
        Sid    = "LambdaInvokePermission",
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = var.lambda_function_arn
      },
      {
        Sid    = "PipeLogging",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:ca-central-1:355366859697:log-group:/aws/vendedlogs/pipes/${var.pipe_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_full_access" {
  role       = aws_iam_role.pipe_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "stepfunctions_full_access" {
  role       = aws_iam_role.pipe_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}



