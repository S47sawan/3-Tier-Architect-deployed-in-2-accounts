# ===================================================================================================================
# vpc endpoint variables
# ===================================================================================================================
variable "vpc_endpoints" {
  type        = map(any)
  description = "A map that defines all VPC endpoints"
  default     = {}
}
# ===================================================================================================================
# resource creation
# ===================================================================================================================
resource "aws_vpc_endpoint" "env_vpc_ep" {
  for_each = { for key, value in var.vpc_endpoints :
    key => value
  if lookup(value, "create_vpc_endpoint", false) == true }
  vpc_id             = aws_vpc.env_vpc[0].id
  service_name       = lookup(each.value, "service_name", "")
  vpc_endpoint_type  = lookup(each.value, "vpc_endpoint_type", "")
  security_group_ids = [for sg in lookup(each.value, "sg_name", []) : aws_security_group.ec2_sg[sg].id]
  subnet_ids         = [aws_subnet.env_subnet[each.value.wp_subnet_a].id, aws_subnet.env_subnet[each.value.wp_subnet_b].id]
  tags = merge(
    local.default_tags,
    {
      "Name" = lookup(each.value, "vpc_ep_name", "")
    },
  )
  depends_on = [aws_vpc.env_vpc]
}
