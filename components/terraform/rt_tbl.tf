# ==================================================================================================================
#VARIABLE
#===================================================================================================================
variable "vpc_destination_cidr" {
  description = "value"
  default     = ""
}
#===================================================================================================================
# Route Tables
# ===================================================================================================================
# ===================================================================================================================
# Resource created so that each individual subnet will have its own route table
# ===================================================================================================================
resource "aws_route_table" "env_rt_tbl" {
  for_each = local.subnets
  vpc_id   = aws_vpc.env_vpc[0].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-${lookup(each.value, "name", "")}-rtbl"
    }
  )
}
#----------------------------------------------------------------------------------------------------------------------
# Routes
#----------------------------------------------------------------------------------------------------------------------
# route traffic to vpc b
#---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env-rt-vpc-b" {
  for_each = { for key, value in local.subnets : key => value
    if var.create_tgw == true
  }
  route_table_id         = aws_route_table.env_rt_tbl[each.key].id
  destination_cidr_block = var.vpc_destination_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
}
#------------------------------------------------------------------------------------------------------------------------------------------
# route traffic to vpc a
# Subnets used in this resource are form the ips_and_cidrs.tf . It includes both the subnets and tgw_subnets merged from the subnet.tfvars
#--------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env-rt-vpc-a" {
  for_each = { for key, value in local.subnets : key => value
    if var.create_tgw == false
  }
  route_table_id         = aws_route_table.env_rt_tbl[each.key].id
  destination_cidr_block = var.vpc_destination_cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.env_mgmt_account_tgw[0].id
}
#----------------------------------------------------------------------------------------------------------------------------------------------
# Route traffic to Internet gateway (IGW)
# The subnets in this resource are from the subnet.tfvars
#------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env-rt-igw" {
  for_each = { for key, value in var.subnets : key => value
    if var.create_tgw == true
  }
  route_table_id         = aws_route_table.env_rt_tbl[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id

}
# #--------------------------------------------------------------------------------------------------------------------------------------
# # traffic from vpc b routed to tgw
# # As tgw is not created in vpc b , data.ec2_transit_gateway is used.
# #-----------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env-rt-tgw" {
  for_each = { for key, value in var.subnets : key => value
    if var.create_tgw == false
  }
  route_table_id         = aws_route_table.env_rt_tbl[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.env_mgmt_account_tgw[0].id
}
#--------------------------------------------------------------------------------------------------------------------------------------
# traffic from vpc routed to ngw
#-----------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env-rt-nat" {
  for_each               = var.tgw_subnets
  route_table_id         = aws_route_table.env_rt_tbl[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.env_nat[0].id
}
#--------------------------------------------------------------------------------------------------------------------------------------
# Associate each subnet to its route table
#-----------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "env_tr_assot" {
  for_each       = local.subnets
  subnet_id      = aws_subnet.env_subnet[each.key].id
  route_table_id = aws_route_table.env_rt_tbl[each.key].id
}




