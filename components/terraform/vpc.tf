# ======================================================================================================================
# Virtual Private Cloud
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "create_vpc" {
  description = "A flag to build a VPC or not. true or false"
  default     = {}
}
variable "vpc_name" {
  description = "name of the bucket created in the region"
  default     = {}
}
variable "env_vpc" {
  description = "Virtual Private Cloud to be configured in each env, in this case account-a(public) and account-b (private)"
  default     = {}
}
variable "vpc_cidr" {
  description = "The CIDR range of the VPC"
  default     = {}
}
variable "enable_vpc_dns_hostnames" {
  description = "A flag to determine whether or not to enable VPC DNS host names"
  default     = {}
}
variable "enable_vpc_dns_support" {
  description = "A flag to determine whether or not to enable DNS support"
  default     = {}
}
variable "tag_owner" {
  description = "System or component owner. Defaults to Mobilise in global_variables.tf"
  default     = {}
}
variable "tag_project" {
  description = "Project that consumes the resource"
  default     = {}
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create VPC 
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "env_vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_vpc_dns_support
  enable_dns_hostnames = var.enable_vpc_dns_hostnames
  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${var.vpc_name}"
      "Owner"   = var.tag_owner
      "Project" = var.tag_project
    },
  )
}