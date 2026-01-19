# OUTPUT

output "lb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.elpharco-webtier-alb.arn
}

output "lb_dns_name" {
  description = "DNS name of ALB."
  value       = aws_lb.elpharco-webtier-alb.dns_name
}