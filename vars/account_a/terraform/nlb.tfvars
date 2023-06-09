# ----------------------------------------------------------------------------------------------------------------------
# Network Load Balancera Variables
# ----------------------------------------------------------------------------------------------------------------------

lbs = {
  "squid_proxy_lb" = {
    "create_lb"   = true
    "lb_name"     = "squid-proxy-lb"
    "lb_internal" = false
    "lb_czlb"     = true
    "proxy_subnet_a" = "public_subnet_01"
    "proxy_subnet_b" = "public_subnet_02"
    "tag_owner"   = "Mobilise-Academy"
    "tag_project" = "Workshop"
  }
}

lb_listeners = {
  "squid_nlb_80_f" = {
    "create_lb"             = true
    "lb_resource"           = "squid_proxy_lb"
    "port"                  = 80
    "protocol"              = "TCP"
    "target_group_resource" = "squid_nlb_tg_01"
  }
}

lb_target_groups = {
  "squid_nlb_tg_01" = {
    "create_lb_tg"   = true
    "tg_name"        = "squid-nlb-tg-01"
    "tg_port"        = 80
    "tg_protocol"    = "TCP"
    "tg_target_type" = "instance"
    "hc_protocol"    = "TCP"
  }
}

lb_targets = {
  # Squid NLB targets 01 
  "squid_target_1" = {
    "create_target"         = true
    "target_group_resource" = "squid_nlb_tg_01"
    "target_id"             = "squid_proxy_01"
  }
  # Squid NLB targets 02 
  "squid_target_2" = {
    "create_target"         = true
    "target_group_resource" = "squid_nlb_tg_01"
    "target_id"             = "squid_proxy_02"
  }
}
