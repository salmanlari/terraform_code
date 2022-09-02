#vpc_cidr

variable "vpccidr" {
  
   }

 #SUBNET

# variable "snetcidr" {
# }


#ROUTE TABLE

variable "routecidr" {
    type = string
    default = "0.0.0.0/0"
  
}
variable "env" {}

variable "pub-subnet" {
  type = map(object({
   pub-cidr =  string
    pub-az   = string

  })) 
}

variable "pvt-subnet" {
  type = map(object({
    pvt-cidr =  string
    pvt-az   = string

  })) 
}

# variable "is_nat_required" {
# }
# variable "nat-pub-id" {
  
# }

