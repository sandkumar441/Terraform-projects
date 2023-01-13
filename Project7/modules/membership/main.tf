resource "aws_iam_group_membership" "membership" {
  group = var.membership_groupname
  name  = "mem1"
  users = [var.membership_username]
}