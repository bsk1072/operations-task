resource "aws_cloudwatch_log_group" "rates-log-group" {
  name              = "/ecs/rates-app"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "rates-log-stream" {
  name           = "rates-app-log-stream"
  log_group_name = aws_cloudwatch_log_group.rates-log-group.name
}

