# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "bastion_instances" {
  description = "A map of all ec2 istances. Each key in this map will have a value that is another map and it's this maop that defines the ec2 characteristics"
  default     = {}
}
variable "create_bastion_instance" {
  description = "This is flag that is used to set the creation of ec2 instances in an account"
  default     = ""
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
#-----------------------------------------------------------------------------------------------------------------------
# Create EC2 instance
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "bastion_instances" {
  for_each = { for key, value in var.bastion_instances :
    key => value
  if lookup(value, "create_bastion_instance", false) == true }
  ami           = lookup(each.value, "ami", "")
  instance_type = lookup(each.value, "instance_type", "")
  # subnet_id                 = element(aws_subnet.env_subnet.*.id, lookup(each.value, "subnet_name", ""))
  subnet_id                   = aws_subnet.env_subnet[lookup(each.value, "subnet_name", "")].id
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", true)
  private_ip                  = lookup(each.value, "private_ip", "")
  key_name                    = lookup(each.value, "ec2_account_key_name")
  vpc_security_group_ids      = [for sg in lookup(each.value, "sg_names", []) : aws_security_group.ec2_sg[sg].id]
  iam_instance_profile        = lookup(each.value, "iam_instance_profile", null) != null ? lookup(each.value, "iam_instance_profile", "") : null
  monitoring                  = lookup(each.value, "monitoring", null)
  user_data                   = lookup(each.value, "user_data", null) != null ? templatefile("${path.module}/${lookup(each.value, "user_data", "")}", {}) : null

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${lookup(each.value, "tag_name", "")}"
      "Owner"   = lookup(each.value, "tag_owner", "")
      "Project" = var.tag_project
    }
  )
  volume_tags = {
    "Name"    = lookup(each.value, "tag_name", "")
    "Owner"   = lookup(each.value, "tag_owner", null)
    "Project" = lookup(each.value, "tag_project", "")
  }
}