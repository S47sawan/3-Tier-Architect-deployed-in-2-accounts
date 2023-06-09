launch_template = {
    wordpress_lt = {
        create_wp_lt = true
        name = "wordpress-lt"
        wp_ami_id = "ami-076fcd2e8e5c00356"
        wp_instance_type = "t2.micro"
        key_name = "wordpressec2kp"
        sg_id = ["wordpress_ec2_sg"]
  }
}

wp_asg = {
  wordpress_asg ={
      create_wp_asg = true
      name = "wordpress-asg"
      health_check_type = "ELB"
      desired_ec2 = "2"
      max_ec2 = "2"
      min_ec2 = "2"
      wp_subnet_a = "pvt_sub_app_01"
      wp_subnet_b = "pvt_sub_app_02"
      hcgp = 300
      lt_resource_name = "wordpress_lt"
      alb_target_group_resource_name = "wordpress_alb_tg"
  }
}





