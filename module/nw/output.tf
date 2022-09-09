output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}
output "dev-snet-id" {
  value = aws_subnet.dev-pub-snet
  }

# output "dev-snet-id" {
#   value =  {for k,v in aws_subnet.dev-pub-snet: k =>v.id}
#   }

  output "pub-snet-id" {
    value = aws_subnet.dev-pub-snet
  }