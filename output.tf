output "security_group" {
  description = "Security group"
  value       = aws_security_group.create_security_group
}

output "security_group_arn" {
  description = "Security group ARN"
  value       = aws_security_group.create_security_group.arn
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.create_security_group.id
}

output "security_group_ingress_rules" {
  description = "Security group ingress rules"
  value       = aws_security_group.create_security_group.ingress
}

output "security_group_egress_rules" {
  description = "Security group egress rules"
  value       = aws_security_group.create_security_group.egress
}
