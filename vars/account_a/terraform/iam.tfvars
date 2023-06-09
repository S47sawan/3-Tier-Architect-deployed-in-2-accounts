#--------------------------------------------------------------------------------------------
# Variables
#--------------------------------------------------------------------------------------------
user_details = {
  MobiliseAcademy_001 = {
    policies = ["AmazonS3FullAccess", "IAMUserChangePassword"]
    groups   = ["mob_academy_grp"]
  }
}
iam_groups = {
  mob_academy_grp = {
    policies    = ["workshop-s3-deny-delete-policy"]
    description = "This is group is created to stop object deletion from s3 bucket"
  }
}
iam_role_policy_templates = {
  "ssm_managed_instance_core" = {
    "name"        = "ssm-managed-instance-core"
    "description" = "policy to use ssm for managing instances"
    "policy"      = "ssm_managed_instance_core.json"
  }
}


# Squid variable
create_squid_iam_profile = true
iam_role_01_policy_01_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
iam_role_01_policy_02_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"


