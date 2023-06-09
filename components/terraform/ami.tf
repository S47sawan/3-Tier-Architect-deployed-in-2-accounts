# ======================================================================================================================
# AMAZON MACHINE IMAGE  (AMI)
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "create_wp_ami" {
  description = "Flag used to set creation of ami image in account"
  default     = ""
}
variable "ami_name" {
  description = "Unique name for the ami created from an esisitng instance"
  default     = ""
}
variable "wp_ec2" {
  description = "Ec2 from which ami image will be made"
  default     = "wordpress-01"
}
variable "source_wp_ec2_id" {
  description = "ID of the instance from which the ami will be created , in this case its the mob-wordpress-01 instance in account b"
  default     = ""
}
# ======================================================================================================================
# Create AMI 
# ======================================================================================================================

resource "aws_ami_from_instance" "mob_wordpress_ami" {
  count              = var.create_wp_ami ? 1 : 0 * length(var.wp_ec2)
  name               = var.ami_name
  source_instance_id = var.source_wp_ec2_id

  depends_on = [
    aws_instance.instance_standard,
  ]

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${var.ami_name}"
      "Owner"   = var.tag_owner
      "Project" = var.tag_project
    },
  )
}

