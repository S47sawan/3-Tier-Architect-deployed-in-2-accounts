#---------------------------------------------------------------------------------------------------------------------------------------
#efs file system variables
#-------------------------------------------------------------------------------------------------------------------------------------------

env_efs = {
  env_efs_01 = {
    create_env_efs         = true
    creation_token         = "env_efs"
    availability_zone_name = "eu-west-2a"
    encrypted              = true
    kms_key_id             = "arn:aws:kms:eu-west-2:679749876012:key/acaa2f8a-5f3f-45da-b8a8-d16506fd88b8"
    performance_mode       = "generalPurpose"
    throughput_mode        = "bursting"
  }
}
#---------------------------------------------------------------------------------------------------------------------------------------
# efs mount target variables
#-------------------------------------------------------------------------------------------------------------------------------------------
efs_mt_tg = {
 efs_mt_tg_01 = {
    creation_token = "env_efs_01"
    create_efs_mt_tg = true
    security_group = "env_efs_sg"
    }
}



