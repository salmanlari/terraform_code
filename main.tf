provider "aws" {
    region = "ap-south-1"
    
} 

module "nw" {
source = "./module/nw"
vpccidr = "10.0.0.0/20"
pub-subnet={
        pub_sub-1 = {
         pub-az   = "ap-south-1a"
         pub-cidr = "10.0.0.0/22"
},
         pub_sub-2  = {
         pub-az     = "ap-south-1b"
         pub-cidr   = "10.0.4.0/22"
        }
} 
pvt-subnet={
        pvt_sub-1  = {
         pvt-az    = "ap-south-1a"
         pvt-cidr  = "10.0.8.0/22"
},
         pvt_sub-2 = {
         pvt-az    = "ap-south-1b"
         pvt-cidr  = "10.0.12.0/22"
        }
}        
# is_nat_required  = false
#     nat-pub-id   ="pub_sub-1"
env = "dev"
}

# output "pub-snet-id" {
#   value = lookup(module.nw.pub-snet-id,"pub_sub-1",null).id
# }


module "sg" {
    source = "./module/sg"
   sg_details = {
    ec2-sg ={
        name   ="ec2"
        description = "all incoming"
        vpc_id = module.nw.dev-vpc-id
        ingress_rules =[
           {
                from_port   = "80"
                to_port     = "80"
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                self        = null                
            },
            {
                from_port    = "22"
                to_port      = "22"
                protocol     = "tcp"
                cidr_blocks  = ["0.0.0.0/0"]
                self         = null
            },
            # {
            #     from_port    = "3306"
            #     to_port      = "3306"
            #     protocol     = "tcp"
            #     cidr_blocks  = ["0.0.0.0/0"]
            #     self         = null
            # }
        ]
    },
    lb-sg ={
        name ="lb"
        description = "lb-sg"
        vpc_id = module.nw.dev-vpc-id
        ingress_rules =[
            {
                from_port    = "80"
                to_port      = "80"
                protocol     = "tcp"
                cidr_blocks  = ["0.0.0.0/0"]
                self         = null
            },
            ]
    }
    }
}

# module "sg2" {
#     source = "./module/sg"
#     sg_details = {
#     rds-sg ={
#         name         ="rds"
#         description  = "rds"
#         vpc_id       = module.nw.dev-vpc-id
#         ingress_rules =[
#            {
#                 from_port   = "3306"
#                 to_port     = "3306"
#                 protocol    = "tcp"
#                 cidr_blocks = ["0.0.0.0/0"]
#                 self        = null 
#                 security_groups = [lookup(module.sg.dev-sg-id, "ec2-sg", null)]               
#             }
            
#         ]
#     }
#     }
# }

# EC2 MODULE
# module "ec2" {
#     source             = "./module/ec2"
#     ami-id             = "ami-068257025f72f470d"  
#     ec2-type           = "t2.micro" 
#     #  snet = lookup(module.nw.pub-snet-id,"pub_sub-1",null).id               #(use for single ec2)
#     snet1 ={                                                                  #(use for multipul ec2)
#         snet-1={
#             subnet = lookup(module.nw.pub-snet-id ,"pub_sub-1",null).id  
#              name = lookup(module.nw.pub-snet-id ,"pub_sub-1",null).availability_zone
#         },
        
#             snet-2={
#                 subnet= lookup(module.nw.pub-snet-id,"pub_sub-2",null).id
#                  name = lookup(module.nw.pub-snet-id ,"pub_sub-2",null).availability_zone
#              }    
#     }
#     sg                   = lookup(module.sg.dev-sg-id, "ec2-sg", null)
    # pubsnet1           = lookup(module.nw.pub-snet-id, "pub_sub-1",null).id
    # pubsnet2           = lookup(module.nw.pub-snet-id, "pub_sub-2", null).id
     
    #  db_name           = module.rds.dbname
    #  username          = module.rds.username
    #  password          = module.rds.password
    #  db_instance       = module.rds.dbhost

     
     
# }

# module "rds"{
#     source = "./module/rds"

#      db_name            = "db_rds"
#      username           = "admin"
#      password           = "qwerty123"
#      rds-sg             = lookup(module.sg2.dev-sg-id, "rds-sg", null)
#      pubsnet1           = lookup(module.nw.pub-snet-id, "pub_sub-1",null).id
#      pubsnet2           = lookup(module.nw.pub-snet-id, "pub_sub-2", null).id
     

# }


#LOAD BALANCER MODULE

module "lb" {
    source               = "./module/lb"
    alb-type             = false
    # tg_attachment      = length(module.ec2.ec2-target-id)
    sg_groups            = [lookup(module.sg.dev-sg-id,"lb-sg",null)]
    snets1               = [lookup(module.nw.dev-snet-id,"pub_sub-1",null).id,lookup(module.nw.dev-snet-id,"pub_sub-2",null).id]
    # snets1             = lookup(module.nw.dev-snet-id,"pub_sub-1",null).id
    # snets2             = lookup(module.nw.dev-snet-id,"pub_sub-2",null).id
    vpc-id               = module.nw.dev-vpc-id
    tg-type              = "instance"
    # ec2-id             = module.ec2.ec2-target-id
    # ec2-id = {
    #   tg_attach-1= {
    #     ec2_tg_id        = lookup(module.ec2.ec2_instance_output,"snet-1",null)
    #   },
    #   tg_attach-2={
    #     ec2_tg_id        = lookup(module.ec2.ec2_instance_output,"snet-2",null)
    #   }
    # }
    port               = 80
    }

# #AUTO SCALING MODULE

module "asg" {
    source            = "./module/asg"
    sg_groups         = [lookup(module.sg.dev-sg-id,"lb-sg",null)]
    key-name          = "mumbai_key"  
    pub-snet          = [lookup(module.nw.dev-snet-id,"pub_sub-1",null).id, lookup(module.nw.dev-snet-id,"pub_sub-2",null).id]
    tg-arn            = module.lb.tg-arn
    ami-id            = "ami-0d06c62e05bbd93bd"
    ec2-instance-type = "t2.micro"
    min_ec2           = 2
    max_ec2           = 5
    hc_ec2            = 300

}

 # output "ec2-id" {
 #   value = module.ec2.*.ec2-target-id
 # }
