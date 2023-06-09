# ----------------------------------------------------------------------------------------------------------------------
# Subnet Specific Variables
# ----------------------------------------------------------------------------------------------------------------------
subnets = {
  public_subnet_01 = {
    "name"         = "public-subnet-01"
    "az"           = "eu-west-2a"
    "cidr"         = "10.2.0.0/27"
    "project_tags" = "Mobilise-Workshop"
  }
  public_subnet_02 = {
    "name"         = "public-subnet-02"
    "az"           = "eu-west-2b"
    "cidr"         = "10.2.0.32/27"
    "project_tags" = "Mobilise-Workshop"
  }
  nat_public_subnet = {
    "name"         = "nat-public-subnet"
    "az"           = "eu-west-2a"
    "cidr"         = "10.2.0.64/27"
    "project_tags" = "Mobilise-Workshop"
  }
}
tgw_subnets = {
  tgw_a_att_subnet = {
    "name"         = "tgw-a-att-subnet"
    "az"           = "eu-west-2a"
    "cidr"         = "10.2.0.96/27"
    "project_tags" = "Mobilise-Workshop"
  }
  tgw_b_att_subnet = {
    "name"         = "tgw-b-att-subnet"
    "az"           = "eu-west-2b"
    "cidr"         = "10.2.0.128/27"
    "project_tags" = "Mobilise-Workshop"
  }
}
