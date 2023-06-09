create_tgw                          = true
create_tgw_local_vpc_amt            = true
create_tgw_route_table              = true
ram_principals                      = "679749876012"
tgw_local_vpc_att_sn_id             = ["tgw_a_att_subnet", "tgw_b_att_subnet"]
default_route_table_propagation     = "disable"
default_route_table_association     = "disable"
tgw_default_route_table_propagation = false
tgw_default_route_table_association = false
create_tgw_atch                     = false
transit_gateway_asn                 = "64527"
atch_name                           = "vpc-a-pub-vpc-b-pvt"
tgw_atch_subnet_ids                 = ["tgw_a_att_subnet", "tgw_b_att_subnet"]
tgw_vpc_attachments = {
  "mob-vpc-b-pvt" = "vpc-08a3813ee2a914cb1"
}

# This sends the traffic from the tgw to the internet
tgw_local_routes = {
  "tgw_to_internet" = {
    "tgw_vpc_attachments"    = "local"
    "destination_cidr_block" = "0.0.0.0/0"
  }
}

