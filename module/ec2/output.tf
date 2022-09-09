# output "ec2-target-id" {
#   value = aws_instance.ec2.id
# }

output "ec2_instance_output" {
    value = {for k,v in aws_instance.ec2: k=>v.id}
  
}