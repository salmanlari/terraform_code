variable "ami-id" {
}

variable "ec2-type" {  
}

variable "sg" {

}

# variable "snet" {
# }


# variable "pubsnet1" {
  
# }
# variable "pubsnet2" {
  
# }
variable "snet1" {
    type        = map(object({
        subnet  =string
        name    = string
    }))
  
}
  
# }


# variable "ssh_priv_key" {
#     default = "/home/admin1/Downloads/mumbai_key.pem"  
# }

# variable "db_name" {
  
# }
# variable "username" {
  
# }
# variable "password" {
  
# }
# variable "db_instance" {
  
# }