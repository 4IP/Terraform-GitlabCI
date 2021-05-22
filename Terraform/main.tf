provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

module "vpc" {
  source          = "./vpc"
  vpc_cidr        = "10.0.0.0/16"
#  public_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
#  private_cidrs   = ["10.0.3.0/24"]
  public_cidrs    = ["10.0.1.0/24"]
  private_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
}

/** module "ec2" {
  source         = "./ec2"
  my_public_key  = "/tmp/ariefjr.pub"
  instance_type  = "t2.medium"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.private_subnets}"
}**/

module "alb" {
  source = "./alb"
  vpc_id = "${module.vpc.vpc_id}"
  private_subnet1 = "${module.vpc.private_subnet1}"
  private_subnet2 = "${module.vpc.private_subnet2}"
}

module "auto_scaling" {
  source           = "./auto_scaling"
  vpc_id           = "${module.vpc.vpc_id}"
  private_subnet1  = "${module.vpc.private_subnet1}"
  private_subnet2  = "${module.vpc.private_subnet2}"
  target_group_arn = "${module.alb.alb_target_group_arn}"
}

/** module "cloudwatch" {
  source      = "./cloudwatch"
  instance_id = "${module.ec2.instance_id}"
} **/