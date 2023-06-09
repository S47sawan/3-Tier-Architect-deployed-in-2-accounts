# ----------------------------------------------------------------------------------------------------------------------
# Variables for EC2 instances
# ----------------------------------------------------------------------------------------------------------------------
ec2s = {
  "wordpress-01" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-00785f4835c6acf64"
    instance_type               = "t2.micro"
    monitoring                  = false
    iam_instance_profile        = null
    subnet_name                 = "pvt_sub_app_01"
    associate_public_ip_address = true
    ec2_account_key_name        = "wordpressec2kp"
    user_data                   = "./templates/user_data/wp-user-data.sh"
    tag_name                    = "wordpress-01"
    tag_project                 = "Mobilise-Workshop"
    tag_owner                   = "Mobilise"
  }
  "wordpress-02" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-00785f4835c6acf64"
    instance_type               = "t2.micro"
    monitoring                  = false
    iam_instance_profile        = null
    subnet_name                 = "pvt_sub_app_02"
    associate_public_ip_address = true
    ec2_account_key_name        = "wordpressec2kp"
    user_data                   = "./templates/user_data/wp-user-data.sh"
    tag_name                    = "wordpress-02"
    tag_project                 = "Mobilise-Workshop"
    tag_owner                   = "Mobilise"
  }

  "wordpress-test" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-076fcd2e8e5c00356"
    instance_type               = "t2.micro"
    monitoring                  = false
    iam_instance_profile        = null
    subnet_name                 = "pvt_sub_app_02"
    associate_public_ip_address = true
    ec2_account_key_name        = "wordpressec2kp"
    user_data                   = "./templates/user_data/wp-user-data.sh"
    tag_name                    = "wordpress-test"
    tag_project                 = "Mobilise-Workshop"
    tag_owner                   = "Mobilise"
  }
}
