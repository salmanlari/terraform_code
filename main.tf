provider "aws" {
    region = "ap-south-1"
    
} 


module "nw" {
source = "./module/nw"
vpccidr = "10.0.0.0/20"
pub-subnet={
        pub_sub-1 = {
         az = "ap-south-1a"
         cidr = "10.0.1.0/24"
},
         pub_sub-2 = {
         az = "ap-south-1b"
         cidr = "10.0.2.0/24"
        }
}        
# snetcidr = ["10.0.1.0/24", "10.0.2.0/24"]  
env = "dev"
}

# module "sg" {
#     source = "./module/sg"
#    sg_details = {
#     ec2-sg ={
#         name   ="ec2"
#         description = "all incoming"
#         vpc_id = module.nw.dev-vpc-id
#         ingress_rules =[
#            {
#                 from_port   = "80"
#                 to_port     = "80"
#                 protocol    = "tcp"
#                 cidr_blocks = ["0.0.0.0/0"]
#                 self        = null                
#             },
#             {
#                 from_port    = "22"
#                 to_port      = "22"
#                 protocol     = "tcp"
#                 cidr_blocks  = ["0.0.0.0/0"]
#                 self         =null
#             }
#         ]
#     },
#     lb-sg ={
#         name ="lb"
#         description = "lb-sg"
#         vpc_id = module.nw.dev-vpc-id
#         ingress_rules =[
#             {
#                 from_port    = "80"
#                 to_port      = "80"
#                 protocol     = "tcp"
#                 cidr_blocks  = ["0.0.0.0/0"]
#                 self         = null
#             },
#             ]
#     }
#   }
# }
# module "ec2" {
#     source = "./module/ec2"
#     count = 2
#     ami-id = "ami-06489866022e12a14"  
#     ec2-type = "t2.micro"
#     snet = module.nw.dev-snet-id[count.index]
#     sg = lookup(module.sg.dev-sg-id, "ec2-sg", null)
     
# }

# module "lb" {
#     source = "./module/lb"
#     alb-type = false
#     #tg_attachment = length(module.ec2.ec2-target-id)
#     sg_groups   = [lookup(module.sg.dev-sg-id,"lb-sg",null)]
#     snets       = module.nw.dev-snet-id
#     vpc-id      = module.nw.dev-vpc-id
#     tg-type = "instance"
#     # ec2-id    = module.ec2.*.ec2-target-id
#     port        = 80
#     }

# module "asg" {
#     source = "./module/asg"
#     #vpc-id = module.nw.dev-vpc-id
#     sg_groups    = [lookup(module.sg.dev-sg-id,"lb-sg",null)]
#     key-name     = "mumbai_key"  
#     pub-snet     = module.nw.dev-snet-id
#     tg-arn       = module.lb.tg-arn
#     ami-id       = "ami-0d06c62e05bbd93bd"
#     ec2-instance-type = "t2.micro"

# }




# output "ec2-id" {
#   value = module.ec2.*.ec2-target-id
# }


