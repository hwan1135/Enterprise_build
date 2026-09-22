output "application_url" {
  value = "https://app.dev.${var.public_zone_name}"
}

output "load_balancer_dns_name" {
  value = aws_lb.app.dns_name
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}