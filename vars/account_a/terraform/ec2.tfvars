# ----------------------------------------------------------------------------------------------------------------------
# Variables for EC2 instances
# ----------------------------------------------------------------------------------------------------------------------
ec2s = {
  "squid_proxy_01" = {
    create_instance             = true
    sg_names                    = ["mob_squid_proxy_sg"]
    ami                         = "ami-0fb391cce7a602d1f"
    instance_type               = "t2.micro"
    monitoring                  = true
    iam_instance_profile        = "instance-am-profile"
    subnet_name                 = "public_subnet_01"
    associate_public_ip_address = true
    ec2_account_key_name        = "squid-kp"
    user_data                   = "./templates/user_data/squid-bootstrap.sh"
    tag_name                    = "squid-proxy-01"
    tag_project                 = "Mobilise-Workshop"
    tag_owner                   = "Mobilise"
  }
  "squid_proxy_02" = {
    create_instance             = true
    sg_names                    = ["mob_squid_proxy_sg"]
    ami                         = "ami-0fb391cce7a602d1f"
    instance_type               = "t2.micro"
    monitoring                  = true
    iam_instance_profile        = "instance-am-profile"
    subnet_name                 = "public_subnet_02"
    associate_public_ip_address = true
    ec2_account_key_name        = "squid-kp"
    user_data                   = "./templates/user_data/squid-bootstrap.sh"
    tag_name                    = "squid-proxy-02"
    tag_project                 = "Mobilise-Workshop"
    tag_owner                   = "Mobilise"
  }
}
