# ----------------------------------------------------------------------------------------------------------------------
# Required variables defined and defaulted for the entire infrastructure
# ----------------------------------------------------------------------------------------------------------------------
variable "region_name" {
  description = "Name of the region e.g. eu-west-2"
  default     = "eu-west-2"
}
variable "client_abbr" {
  description = "Abbreviated name of the client e.g Mobilise = 'mob'. Must be declared in each environment.tfvars for the create S3 script"
  default     = "mob"
}
variable "owner" {
  description = "The Owner of the environment e.g Mobilise"
  default     = ""
}
variable "environment_short" {
  type        = string
  description = "Name of the environment the resource is deployed in its short version to avoid long dns names etc."
  default     = ""
}
variable "environment" {
  description = "Name of the environment the resource is deployed to, e.g. dev, test, int, etc."
  default     = ""
}
variable "account_no" {
  description = "AWS Account No e.g. 123456789012"
  default     = ""
}
variable "project" {
  description = "Name of the project e.g Mobilise-Workshop"
  default     = ""
}
variable "environment_azs" {
  description = "Map list of the number of Availability Zones to use and which character to use for the suffix e.g eu-west-2c"
  default     = {}
}
# ----------------------------------------------------------------------------------------------------------------------
# Standard Tags for AWS Resources - see https://www.terraform.io/docs/configuration/locals.html
# ----------------------------------------------------------------------------------------------------------------------
locals {
  default_tags = {
    Environment = var.environment
    Owner       = var.owner
  }

  # --------------------------------------------------------------------------------------------------------------------
  # Standard List Tags for AWS Resources
  # --------------------------------------------------------------------------------------------------------------------
  default_list_tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = var.owner
      propagate_at_launch = true
    }
  ]

  # -------------------------------------------------------------------------------------------------------------------
  # Name prefix for all named resouces which follows the Mobilise Cloud Handbook:
  # example: mob-mgmt-jenkins-rtbl
  # -------------------------------------------------------------------------------------------------------------------

  name_prefix = var.client_abbr
}

