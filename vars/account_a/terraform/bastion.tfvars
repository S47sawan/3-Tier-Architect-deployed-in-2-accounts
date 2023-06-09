bastion_instances = {
  bastion_host = {
    create_bastion_instance     = true
    sg_names                    = ["mob_bastion_sg"]
    ami                         = "ami-0fb391cce7a602d1f"
    instance_type               = "t2.micro"
    monitoring                  = false
    iam_instance_profile        = null
    subnet_name                 = "public_subnet_01"
    private_ip                  = "10.2.0.29"
    associate_public_ip_address = true
    ec2_account_key_name        = "bastionkp"
    user_data                   = null
    tag_name                    = "bastion-host"
    tag_project                 = "Mobilise-Workshop"
    tag_owner                   = "Mobilise"
  }
}


