output "role_arn" {
  description = "IAM Role ARN for Lambda"
  value       = aws_iam_role.step_func_parser_lambda_exec_role.arn
}
