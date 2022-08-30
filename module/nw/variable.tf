#vpc_cidr
variable "vpccidr" {
   }
 #subnet
# variable "snetcidr" {
# }
#route table
variable "routecidr" {
    type = string
    default = "0.0.0.0/0"
  
}
variable "env" {}

variable "pub-subnet" {
  type = map(object({
    cidr =  string
    az   = string

  })) 
}

