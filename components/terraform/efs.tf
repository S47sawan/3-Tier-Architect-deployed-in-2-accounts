# =================================================================================================================================================================
# Variables
# ==================================================================================================================================================================
variable "env_efs" {
  description = "Map of efs file system"
  default     = {}
}
variable "create_env_efs" {
  description = "This is a flag used to set the deployment of efs file system in an environment"
  default     = ""
}
variable "efs_mt_tg" {
  description = "map of mount targets for efs in vpc b env"
  default     = {}
}
variable "create_efs_mt_tg" {
  description = "This is a flag used to set deployment of mount targets in env"
  default     = ""
}
variable "efs_subnet_a" {
  description = "subnet that will usd for efs mount target"
  default     = "pvt_sub_data_01"
}
# =================================================================================================================================================================
# Resource Elastic File System (efs)  - storage system
# =================================================================================================================================================================
resource "aws_efs_file_system" "env_efs" {
  for_each = { for key, value in var.env_efs :
    key => value
  if lookup(value, "create_env_efs", false) == true }
  creation_token         = lookup(each.value, "creation_token", "")
  availability_zone_name = lookup(each.value, "availability_zone_name", "")
  encrypted              = lookup(each.value, "encrypted", "")
  kms_key_id             = lookup(each.value, " kms_key_id", "")
  performance_mode       = lookup(each.value, "performance_mode", "")
  throughput_mode        = lookup(each.value, "throughput_mode", "")

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
}
#---------------------------------------------------------------------------------------------------------------------------------------
#Create efs mount target
#-------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_efs_mount_target" "efs_mt_tg" {
  for_each = var.efs_mt_tg 
  # for_each = { for key, value in var.efs_mt_tg :
  #   key => value
  # if lookup(value, "create_efs_mt_tg", false) == true }
  file_system_id  = aws_efs_file_system.env_efs[each.value.creation_token].id
  subnet_id       = aws_subnet.env_subnet[var.efs_subnet_a].id
  security_groups = [aws_security_group.ec2_sg[lookup(each.value, "security_group", "")].id]

  depends_on = [
    aws_efs_file_system.env_efs
  ]
}
