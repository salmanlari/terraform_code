output "dev-sg-id" {
    value={for k , v in aws_security_group.sg: k => v.id}  
}
