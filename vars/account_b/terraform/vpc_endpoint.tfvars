# ===================================================================================================================
# vpc endpoint variables
# ===================================================================================================================
vpc_endpoints = {
  "ssm_endpnt" = {
    "create_vpc_endpoint" = true
    "vpc_ep_name"         = "ssm-endpnt"
    "service_name"        = "com.amazonaws.eu-west-2.ssm"
    "vpc_endpoint_type"   = "Interface"
    "sg_name"             = ["mob_ssm_endpoint_sg"]
    # "subnet_ids"          = ["0", "1"]
     "wp_subnet_a" = "pvt_sub_app_01"
     "wp_subnet_b" = "pvt_sub_app_02"
  }
  "ssmmessages_endpnt" = {
    "create_vpc_endpoint" = true
    "vpc_ep_name"         = "ssmmessages-endpnt"
    "service_name"        = "com.amazonaws.eu-west-2.ssmmessages"
    "vpc_endpoint_type"   = "Interface"
    "sg_name"             = ["mob_ssm_endpoint_sg"]
    # "subnet_ids"          = ["0", "1"]
    "wp_subnet_a" = "pvt_sub_app_01"
     "wp_subnet_b" = "pvt_sub_app_02"
  }
  "ec2messages_endpnt" = {
    "create_vpc_endpoint" = true
    "vpc_ep_name"         = "ec2messages-endpnt"
    "service_name"        = "com.amazonaws.eu-west-2.ec2messages"
    "vpc_endpoint_type"   = "Interface"
    "sg_name"             = ["mob_ssm_endpoint_sg"]
    # "subnet_ids"          = ["0", "1"]
     "wp_subnet_a" = "pvt_sub_app_01"
     "wp_subnet_b" = "pvt_sub_app_02"
  }
}

