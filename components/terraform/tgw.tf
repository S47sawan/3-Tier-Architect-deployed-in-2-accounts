# ===================================================================================================================
# Transit Gateway - Excluding the transit gateway attachments
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_tgw" {
  description = "A flag to include a transit gateway. true or false"
  default     = false
}
variable "transit_gateway_asn" {
  description = "The asn of the transit gateway. Default is 64512."
  default     = "64527"
}
variable "tgw_name_suffix" {
  description = "The transit gateway doesn't use the standard client-account as a name. Use this to ensure the name tag meets the design spec"
  default     = "tgw-01"
}
variable "ram_principals" {
  description = "A list of all the other accounts the transit gateway should share with"
  default     = []
}
variable "tgw_local_vpc_att_sn_id" {
  description = "A list of the subnet name (as defined in subnet.tfvars) for the local transit gateway VPC attachment"
  default     = []
}
variable "tgw_vpc_attachments" {
  description = "A map of the VPC ids and the account names they belong to. Required for naming transit gateway attachments"
  default     = {}
}
variable "create_tgw_local_vpc_amt" {
  description = "A flag to create a vpc attachment to the local VPC. true or false"
  default     = false
}
variable "tgw_local_routes" {
  description = "map of tgw local routes"
  default     = {}
}
variable "tgw_routes" {
  description = "map of tgw routes"
  default     = {}
}
variable "create_tgw_route_table" {
  description = "flag used to set the creation of tgw route tables"
  default     = false
}
variable "default_route_table_association" {
  description = "This is set to disable"
  default     = ""
}
variable "tgw_default_route_table_association" {
  description = "This is set to disable"
  default     = ""
}
variable "default_route_table_propagation" {
  description = "tgw default route table propagation"
  default     = false
}
variable "tgw_default_route_table_propagation" {
  description = "tgw default route table propagation"
  default     = false
}
variable "create_tgw_atch" {
  description = "A flag used to control whether the attachment is created or not. True or false"
  default     = false
}
variable "atch_name" {
  description = "The string to use as a name tag for the attachement"
  default     = ""
}
variable "tgw_atch_subnet_ids" {
  description = "A list of subnet ids as defined in subnet.tfvars for the transit gateway attachments"
  default     = []
}
variable "tgw_default_rtbl" {
  description = "A flag whether the VPC Attachment should be associated and propagated with the EC2 Transit Gateway association default route table"
  default     = true
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "env_tgw" {
  count                           = var.create_tgw ? 1 : 0
  description                     = "Connects on-premises networks to multiple VPCs using a single gateway"
  auto_accept_shared_attachments  = "enable"
  amazon_side_asn                 = var.transit_gateway_asn
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(
    local.default_tags,
    {
      "Name" = "${var.client_abbr}-${var.tgw_name_suffix}"
    }
  )
  lifecycle {
    ignore_changes = [default_route_table_association, default_route_table_propagation]
  }
}
# ----------------------------------------------------------------------------------------------------------------------
# The local Transit Gateway vpc a attachment to vpc b
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "env_tg_atmt" {
  count                                           = var.create_tgw_local_vpc_amt ? 1 : 0
  subnet_ids                                      = [for sn in var.tgw_local_vpc_att_sn_id : aws_subnet.env_subnet[sn].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.env_tgw[0].id
  vpc_id                                          = aws_vpc.env_vpc[0].id
  transit_gateway_default_route_table_association = var.tgw_default_route_table_association
  transit_gateway_default_route_table_propagation = var.tgw_default_route_table_propagation
  depends_on                                      = [aws_subnet.env_subnet]


  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-tgw-attach"
    },
  )
}
#===================================================================================================================
#Transit Gateway Attachments - This sets up the cross account transit gateway attachment vpc b to vpc a
#===================================================================================================================
# This sets up the cross account transit gateway attachment.
resource "aws_ec2_transit_gateway_vpc_attachment" "x_act_tg_atmt" {
  count              = var.create_tgw_atch ? 1 : 0
  subnet_ids         = [for sn in var.tgw_atch_subnet_ids : aws_subnet.env_subnet[sn].id]
  transit_gateway_id = data.aws_ec2_transit_gateway.env_mgmt_account_tgw[0].id
  vpc_id             = aws_vpc.env_vpc[0].id

  transit_gateway_default_route_table_association = var.tgw_default_rtbl
  transit_gateway_default_route_table_propagation = var.tgw_default_rtbl

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-${var.atch_name}"
    },
  )
  depends_on = [aws_subnet.env_subnet]
}

# ----------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Tables
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "env_tgw_rtbl" {
  count              = var.create_tgw_route_table ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.env_tgw[0].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${var.environment}-${local.name_prefix}-rtbl"
    },
  )
}
# =========================================================================================================================
# transit gateway data block
# =========================================================================================================================
data "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_att" {
  for_each = var.tgw_vpc_attachments
  filter {
    name   = "vpc-id"
    values = [each.value]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_ec2_transit_gateway" "env_mgmt_account_tgw" {
  count = var.create_tgw_atch ? 1 : 0

  filter {
    name   = "options.amazon-side-asn"
    values = [var.transit_gateway_asn]
  }
}
# =========================================================================================================================
# create tgw route to internet
# =========================================================================================================================
resource "aws_ec2_transit_gateway_route" "tgw_vpc_route" {
  for_each = { for key, value in var.tgw_local_routes :
    key => value
  if lookup(value, "tgw_vpc_attachments", "") == "local" }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.env_tg_atmt[0].id
  destination_cidr_block         = lookup(each.value, "destination_cidr_block", "")
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}
# ----------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Table Associations & Propagation
# -------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_association" "tgw_local_vpc_rt_assoc" {
  count                          = var.create_tgw_local_vpc_amt ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.env_tg_atmt[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_local_vpc_rt_prop" {
  count                          = var.create_tgw_local_vpc_amt ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.env_tg_atmt[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw_foreign_vpc_rt_assoc" {
  for_each                       = var.tgw_vpc_attachments
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_att[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_foreign_vpc_rt_prop" {
  for_each                       = var.tgw_vpc_attachments
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_att[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}

#-----------------------------------------------------------------------------------------------------------------------
#Create RAM resource
#------------------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_share" "env_ram_share" {
  name                      = "mobilise-academy-resource-share"
  allow_external_principals = true

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-resource-share"
    }
  )
}
#-----------------------------------------------------------------------------------------------------------------------
#Create resource association
#------------------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_association" "env-ram-res-assot" {
  count              = var.create_tgw ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.env_tgw[0].arn
  resource_share_arn = aws_ram_resource_share.env_ram_share.arn
}
#-----------------------------------------------------------------------------------------------------------------------
#Create RAM principal association
#------------------------------------------------------------------------------------------------------------------------
resource "aws_ram_principal_association" "ram_principal" {
  principal          = var.ram_principals
  resource_share_arn = aws_ram_resource_share.env_ram_share.arn
}


