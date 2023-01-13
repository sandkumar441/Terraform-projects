module "iamuser" {
  source = "./modules/iamuser"
  usernametocreate = var.iam_username
}

module "iamgroup" {
  source = "./modules/iamgroup"
  iamgroup_create = var.iamgroup_name
}
module "membership" {
  source = "./modules/membership"
  membership_groupname = module.iamgroup.iamgroup_output_groupname
  membership_username = module.iamuser.iamuser_output_username

}

module "SecurityGroup" {
  source = "./modules/SecurityGroup"
  create_sgname = var.sg_name
}

module "EC2Instances" {
  source = "./modules/EC2Instances"
  create_instance-amiid = var.amiid
  create_instance-instancetype = var.instancetype
  create_instance-instance-name = var.instancename
  create_instance-sgname = module.SecurityGroup.sgname_output
}