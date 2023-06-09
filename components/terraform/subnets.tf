# ======================================================================================================================
# SUBNETS
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "subnets" {
  description = "Map list of the names to give to the individual subnets. These can then be referenced by route tables"
  default     = {}
}
variable "tgw_subnets" {
  description = "subnets that have transit gateway "
  default     = {}
}
variable "project_tags" {
  description = "Project that consumes the resource"
  default     = ""
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
resource "aws_subnet" "env_subnet" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.env_vpc[0].id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = merge(
    local.default_tags,
    {
      "Name"    = lookup(each.value, "name", "")
      "Project" = lookup(each.value, "project_tags", "")
    }
  )
}





