# ===================================================================================================================
# Identity and Access Management - Roles,Users,groups policies and policy attachments
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ====================================================================================================================
variable "create_squid_iam_profile" {
  description = "A flag to determine whether or not to create the squid proxy IAM profile"
  default     = false
}
variable "create_squid_ssm_cw_logs" {
  description = "A flag to use an IAM policy to allow the instacne to send logs to CloudWatch"
  default     = false
}
variable "user_details" {
  description = <<EOT
   map of users in the account 
   user_details= {
         MobiliseAcademy_001 = {
         policies = ["AmazonS3FullAccess","IAMUserChangePassword"]
         groups = ["group_name"]
         }
 } 
   EOT
  default     = {}
}
variable "iam_groups" {
  description = "A map of iam groups"
  default     = {}
}
variable "iam_role_policy_templates" {
  type        = map(any)
  description = "map of the role policy templates to create"
  default     = {}
}
variable "iam_role_01_policy_01_arn" {
  type        = string
  description = "map of the group policy templates to create"
  default     = ""
}
variable "iam_role_01_policy_02_arn" {
  type        = string
  description = "map of the group policy templates to create"
  default     = ""
}



#=====================================================================================================================
# Create User
#=====================================================================================================================
resource "aws_iam_user" "mobilise_academy" {
  for_each = var.user_details
  name     = each.key

  tags = merge(
    local.default_tags,
    {
      "Name"    = each.key
      "Project" = var.tag_project
    },
  )
}

#=====================================================================================================================
# Attach iam user policy to user, as the are AWS managed policy, rather than creating them as resource use the policy arn
#=====================================================================================================================
resource "aws_iam_user_policy_attachment" "s3fullaccess_policy_attach" {
  for_each = { for key, value in var.user_details :
    key => value
  if contains(value.policies, "AmazonS3FullAccess") == true }
  user       = aws_iam_user.mobilise_academy[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "iam_user_change_password_policy_attach" {
  for_each = { for key, value in var.user_details :
    key => value
  if contains(value.policies, "IAMUserChangePassword") == true }
  user       = aws_iam_user.mobilise_academy[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}
#=====================================================================================================================
# Create workshop_s3_deny_delete policy
#=====================================================================================================================
resource "aws_iam_policy" "workshop_s3_deny_delete" {
  name   = "workshop_s3_deny_delete"
  policy = data.template_file.workshop_s3_deny_delete.rendered

  tags = merge(
    local.default_tags,
    {
      "Name" = "workshop-s3-deny-delete-policy"
    },
  )
  depends_on = [aws_iam_group.mob_academy_grp]
}
#=====================================================================================================================
# Create ssm policy
#=====================================================================================================================
resource "aws_iam_policy" "ssm_policy" {
  for_each = var.iam_role_policy_templates
  name     = lookup(each.value, "name", "")
  policy   = file("./templates/ssm_managed_instance_core.json")

  tags = merge(
    local.default_tags,
    {
      "Name" = "ssm-managed-instance-core"
    },
  )
  }

  resource "aws_iam_role_policy_attachment" "ssmmanagedinstancecore" {
  count              = var.create_squid_iam_profile ? 1 : 0
  # count      = var.create_iam ? 1 : 0
  role       = aws_iam_role.squid_iam_role[0].id
  policy_arn = var.iam_role_01_policy_01_arn
  depends_on = [aws_iam_role.squid_iam_role]
}
resource "aws_iam_role_policy_attachment" "cloudwatchagentserver" {
  count              = var.create_squid_iam_profile ? 1 : 0
  # count      = var.create_iam ? 1 : 0
  role       = aws_iam_role.squid_iam_role[0].id
  policy_arn = var.iam_role_01_policy_02_arn
  depends_on = [aws_iam_role.squid_iam_role]
}

#=====================================================================================================================
# Create iam group 
#====================================================================================================================
resource "aws_iam_group" "mob_academy_grp" {
  for_each = var.iam_groups
  name     = each.key
}
#=====================================================================================================================
# Create iam group policy attachment
#====================================================================================================================
resource "aws_iam_group_policy_attachment" "mob_academy_grp_attch" {
  for_each = { for key, value in var.iam_groups :
    key => value
  if contains(value.policies, "workshop-s3-deny-delete-policy") == true }
  group      = aws_iam_group.mob_academy_grp[each.key].name
  policy_arn = aws_iam_policy.workshop_s3_deny_delete.arn
}
#=====================================================================================================================
# Create iam group membership
#=====================================================================================================================
resource "aws_iam_group_membership" "env_user_membership" {
  for_each = local.user_membership
  name     = "${each.value.group}-${each.value.user}"
  users    = [aws_iam_user.mobilise_academy[each.value.user].name]
  group    = aws_iam_group.mob_academy_grp[each.value.group].name
}

# ======================================================================================================================
# RESOURCES FOR IAM Squids
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create Squid IAM Role - attach STS Assume Role Policy
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "squid_iam_role" {
  count              = var.create_squid_iam_profile ? 1 : 0
  name               = "${local.name_prefix}-iam-ip-role-squid"
  assume_role_policy = data.template_file.instance_iam_profile_policy.rendered
}
# ----------------------------------------------------------------------------------------------------------------------
# Create a Squid Instance Profile
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "squid_profile" {
  count = var.create_squid_iam_profile ? 1 : 0
  name  = "${var.environment}-squid-iam-ip"
  role  = aws_iam_role.squid_iam_role[0].name
}


