# ===================================================================================================================
# EC2 key pairs. These are actually created manually and imported. Once imported, if lost can be re-created from
# Terraform
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "ec2_keys_pairs" {
  description = "A list of all key pairs created in the account"
  default     = []
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create the key pair in the AWS console then import the key pair.
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "env_ec2_key_pair" {
  for_each   = toset(var.ec2_keys_pairs)
  key_name   = each.key
  public_key = ""
}
