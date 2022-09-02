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
# is_nat_required  = true
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
                self         =null
            }
        ]
    },
    # lb-sg ={
    #     name ="lb"
    #     description = "lb-sg"
    #     vpc_id = module.nw.dev-vpc-id
    #     ingress_rules =[
    #         {
    #             from_port    = "80"
    #             to_port      = "80"
    #             protocol     = "tcp"
    #             cidr_blocks  = ["0.0.0.0/0"]
    #             self         = null
    #         },
    #         ]
    # }
  }
}
module "ec2" {
    source   = "./module/ec2"
    # count    = 2
    ami-id   = "ami-068257025f72f470d"  
    ec2-type = "t2.micro"
    snet     = lookup(module.nw.pub-snet-id, "pub_sub-1", null).id
    sg       = lookup(module.sg.dev-sg-id, "ec2-sg", null)
     pubsnet1 = lookup(module.nw.pub-snet-id, "pub_sub-1",null).id
     pubsnet2=lookup(module.nw.pub-snet-id, "pub_sub-2", null).id
}

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


# #..............................functions........

# module "test" {
#     source = "./module/test"
# }
# output "name" {
# value = module.test.test
# }