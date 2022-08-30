variable "abc" {
  default = ["a","b"]
}

output "name" {
  value=var.abc[2]
}