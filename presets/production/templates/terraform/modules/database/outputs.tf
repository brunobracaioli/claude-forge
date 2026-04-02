output "endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}

output "connection_string" {
  value     = "postgresql://app:${random_password.db.result}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}
