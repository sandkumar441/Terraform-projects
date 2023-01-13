module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"
  name = var.name
}