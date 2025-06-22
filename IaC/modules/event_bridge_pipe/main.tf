resource "aws_cloudwatch_log_group" "pipe_logs" {
  name = "/aws/events/${terraform.workspace}/${var.pipe_name}"
}

resource "aws_pipes_pipe" "pipe" {
  name     = var.pipe_name
  role_arn = var.pipe_role_arn

  source = var.source_arn
  target = var.target_arn
  source_parameters {
    sqs_queue_parameters {
      batch_size = var.batch_size
    }
  }

  target_parameters {
    step_function_state_machine_parameters {
      invocation_type = "FIRE_AND_FORGET"
    }
  }

  log_configuration {
    include_execution_data = ["ALL"]
    level                  = "INFO"
    cloudwatch_logs_log_destination {
      log_group_arn = aws_cloudwatch_log_group.pipe_logs.arn
    }
  }

  tags = {
    Name        = var.pipe_name
    Environment = "${terraform.workspace}"
  }

}
