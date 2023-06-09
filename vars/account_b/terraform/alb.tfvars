# ======================================================================================================================
# ALB VARIABLES
# ======================================================================================================================
# Application load balancers
albs = {
  wordpress-alb = {
    create_albs  = true
    internal    = true
    lb_type     = "application"
    sg_id       = "wordpress_ec2_alb_sg"
    wp_subnet_a = "pvt_sub_app_01"
    wp_subnet_b = "pvt_sub_app_02"
  }
}
# Application load balancer target groups
alb_target_grps = {
  "wordpress_alb_tg" = {
    tg_name             = "wp-alb-tg"
    tg_port             = "80"
    tg_protocol         = "HTTP"
    tg_type             = "instance"
    hc_port             = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    hc_timeout          = 5
    hc_interval         = 30
    hc_protocol         = "HTTP"
    hc_path             = "/"
    success_codes       = "200,302"
  }
}
#Application loab balancer listener forwarding traffic to wordpress instances
alb_listeners = {
  "wordpress_alb_80_f" = {
    create_alb_listener = true
    alb_resource_name              = "wordpress-alb"
    alb                            = "wordpress-alb"
    port                           = 80
    protocol                       = "HTTP"
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_action                     = "forward"
  }
}
# Target groups to be attached to the ALB
alb_targets = {
  "wordpress_tg_01" = {
    add_alb_targets                = false
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_target_resource_name       = "wordpress-01"
  }

  "wordpress_tg_02" = {
    add_alb_targets                = false
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_target_resource_name       = "wordpress-02"
  }

  "wordpress_tg_test" = {
    add_alb_targets                = false
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_target_resource_name       = "wordpress-test"
  }
}



