# ----------------------------------------------------------------------------------------------------------------------
# Subnet Specific Variables
# ----------------------------------------------------------------------------------------------------------------------
subnets = {
  pvt_sub_app_01 = {
    "name"        = "pvt-sub-app-01"
    "az"          = "eu-west-2a"
    "cidr"        = "10.9.0.0/26"
    "project_tag" = "Mobilise-Workshop"
  }
  pvt_sub_app_02 = {
    "name"        = "pvt-sub-app-02"
    "az"          = "eu-west-2b"
    "cidr"        = "10.9.0.64/26"
    "project_tag" = "Mobilise-Workshop"
  }
  pvt_sub_data_01 = {
    "name"        = "pvt-sub-data-01"
    "az"          = "eu-west-2a"
    "cidr"        = "10.9.0.128/26"
    "project_tag" = "Mobilise-Workshop"
  }
  pvt_sub_data_02 = {
    "name"        = "pvt-sub-data-02"
    "az"          = "eu-west-2b"
    "cidr"        = "10.9.0.192/26"
    "project_tag" = "Mobilise-Workshop"
  }
}

environment_azs = {
  "0" = "a"
  "1" = "b"
}


