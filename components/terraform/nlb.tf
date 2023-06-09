# ======================================================================================================================
# RESOURCE NETWORK LOAD BALANCER 
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "create_lb" {
  description = "Creates Network Load Balancer"
  default     = false
}
variable "create_lb_tg" {
  description = "Creates Network Load Balancer target group"
  default     = false
}
variable "lbs" {
  description = "A map of network load balancers"
  default     = {}
}
# Forwarding listener
variable "lb_listeners" {
  description = "A map of network load balancer listeners"
  default     = {}
}
variable "lb_listener_rules_f" {
  description = "A map of all listener rules that have a default action of forward"
  default     = {}
}
variable "lb_target_groups" {
  type        = map(any)
  description = "A map of network load balancer target groups"
  default     = {}
}
variable "lb_targets" {
  description = "A map of target instances linked to the nlb target group"
  default     = {}
}
# variable "proxy_subnet_a" {
#   description = "The number of the subnet to connect to as defined in subnet.tfvars"
#   default     = "public_subnet_01"
# }
# variable "proxy_subnet_b" {
#   description = "The number of the subnet to connect to as defined in subnet.tfvars"
#   default     = "public_subnet_02"
# }
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Network load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "env_lb" {
  for_each = { for key, value in var.lbs :
    key => value
  if lookup(value, "create_lb", false) == true }
  name                             = "${local.name_prefix}-${lookup(each.value, "lb_name", "")}"
  internal                         = lookup(each.value, "lb_internal", "")
  enable_cross_zone_load_balancing = lookup(each.value, "lb_czlb", "")
  load_balancer_type               = "network"
  subnets                          = [aws_subnet.env_subnet[each.value.proxy_subnet_a].id, aws_subnet.env_subnet[each.value.proxy_subnet_b].id]

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${lookup(each.value, "lb_name")}"
      "Owner"   = "${var.tag_owner}"
      "Project" = "${var.tag_project}"
    },
  )
}
# ----------------------------------------------------------------------------------------------------------------------
# NLB Listener 
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "env_lb_lb_listener" {
  for_each = { for key, value in var.lb_listeners :
    key => value
  if lookup(value, "create_lb", false) == true }
  load_balancer_arn = aws_lb.env_lb[lookup(each.value, "lb_resource", 0)].arn
  port              = lookup(each.value, "port", 0)
  protocol          = lookup(each.value, "protocol", "")

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.env_lb_tg[lookup(each.value, "target_group_resource", "")].arn
  }
  depends_on = [aws_lb.env_lb]
}

# ----------------------------------------------------------------------------------------------------------------------
# Network Load Balancer Target Groups
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "env_lb_tg" {
  for_each = { for key, value in var.lb_target_groups :
    key => value
  if lookup(value, "create_lb_tg", false) == true }
  name        = "${local.name_prefix}-${lookup(each.value, "tg_name", true)}"
  port        = lookup(each.value, "tg_port", "")
  protocol    = lookup(each.value, "tg_protocol", "")
  target_type = lookup(each.value, "tg_target_type", "")
  vpc_id      = aws_vpc.env_vpc[0].id
  health_check {
    protocol            = lookup(each.value, "hc_protocol", "HTTP")
    port                = lookup(each.value, "hc_port", "traffic-port")
    # path                = lookup(each.value, "hc_path", "")
    healthy_threshold   = lookup(each.value, "hc_healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value, "hc_unhealthy_threshold", 3)
    timeout             = lookup(each.value, "hc_timeout", null)
    interval            = lookup(each.value, "hc_interval", 30)
  }
  depends_on = [aws_lb.env_lb]
}
# ----------------------------------------------------------------------------------------------------------------------
# Network load balancer targets
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "env_lb_targets" {
  for_each = { for key, value in var.lb_targets :
    key => value
  if lookup(value, "create_target", false) == true }
  target_group_arn = aws_lb_target_group.env_lb_tg[lookup(each.value, "target_group_resource", "")].arn
  target_id        = aws_instance.instance_standard[lookup(each.value, "target_id", "")].id
}




































# # ======================================================================================================================
# # NETWORK LOAD BALANCER
# # ======================================================================================================================

# # ======================================================================================================================
# # VARIABLES FOR THE NETWORK LOAD BALANCER
# # ======================================================================================================================
# variable "create_squid_proxy_lb" {
#   description = "A flag to determine whether to create the squid proxy load balancer"
#   default     = false
# }
# variable "nlb_targets" {
#  description = "squid instances that will be attached to the nlb"
#  default = {}
#  }

# variable "create_squid_proxy_tg" {
#   description = "A flag to determine whether to create the squid proxy target group"
#   default     = false
# }
# variable "create_squid_proxy_http_listener" {
#   description = "A flag to determine whether to a squid proxy HTTP listener"
#   default     = false
# }
# variable "squid_proxy_lbs" {
#   description = "A map of network load balancers"
#   default = {} 
# }
# variable "squid_proxy_lb_listeners" {
#   description = "A map of network load balancer listeners"
#   default     = {}
# }

# variable "squid_proxy_http_port" {
#   description = "The port number to be used by the squid proxy"
#   default     = "80"
# }
# # variable "squid_proxy_https_port" {
# #   description = "The port number to be used by the squid proxy"
# #   default     = "443"
# # }
# variable "squid_proxy_module_name" {
#   description = "The string to include in the name tag"
#   default     = ""
# }
# variable "proxy_subnet_a" {
#   description = "The number of the subnet to connect to as defined in subnet.tfvars"
#   default     = ""
# }

# variable "proxy_subnet_b" {
#   description = "The number of the subnet to connect to as defined in subnet.tfvars"
#   default     = ""
# }
# variable "tag_squid_project" {
#   description = "The value of the Project tag"
#   default     = ""
# }

# # ======================================================================================================================
# # RESOURCES FOR THE SQUID NETWORK LOAD BALANCER
# # ======================================================================================================================
# resource "aws_lb" "squid_proxy_lb" {
#   for_each = { for key, value in var.nlbs :
#     key => value
#   if lookup(value, "create_squid_proxy_lb", false) == true }
#   name                             = "${local.name_prefix}-squid-nlb"
#   load_balancer_type               = "network"
#   internal                         = false
#   subnets                          = [aws_subnet.env_subnet[var.proxy_subnet_a].id, aws_subnet.env_subnet[var.proxy_subnet_b].id]
#   enable_cross_zone_load_balancing = true
#   enable_deletion_protection       = false

#   tags = merge(
#     local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-squid-nlb"
#     },
#   )
# }

# resource "aws_lb_listener" "squid_http_listener" {
#   for_each = { for key, value in var.nlb_listeners :
#     key => value
#   if lookup(value, "create_squid_proxy_http_listener", false) == true }


#   load_balancer_arn = aws_lb.squid_proxy_lb[0].arn
#   port              = var.squid_proxy_http_port
#   protocol          = "TCP"

#   default_action {
#     target_group_arn = aws_lb_target_group.squid_proxy_tg[0].arn
#     type             = "forward"
#   }
# }

# resource "aws_lb_target_group" "squid_proxy_tg" {
#   count    = var.create_squid_proxy_tg ? 1 : 0
#   name     = "${local.name_prefix}-squid-proxy-tg"
#   port     = var.squid_proxy_http_port
#   protocol = "TCP"
#   vpc_id   = aws_vpc.env_vpc[0].id


#   health_check {
#     protocol = "TCP"
#   }

#   tags = merge(
#     local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-${var.squid_proxy_module_name}-tg"
#     },
#   )
# }

# resource "aws_lb_target_group_attachment" "test" {
#   for_each = { for key, value in var.nlb_targets :
#     key => value
#   if lookup(value, "create_squid_proxy_tg", false) == true }
#   target_group_arn = aws_lb_target_group.squid_proxy_tg[0].arn
#   target_id        = aws_instance.instance_standard[each.key].id
#   port             = 80
# }


# # ======================================================================================================================
# # RESOURCES FOR THE SQUID LAUNCH (INSTANCE) CONFIGURATION AND AUTOSCALING
# # ======================================================================================================================
# # resource "aws_launch_configuration" "squid_proxy_lc" {
# #   count                       = var.create_squid_proxy_lc ? 1 : 0
# #   name_prefix                 = "${local.name_prefix}-${var.squid_proxy_module_name}-lc-"
# #   image_id                    = var.squid_proxy_ami
# #   instance_type               = var.squid_proxy_instance_type
# #   security_groups             = [aws_security_group.ec2_sg[var.squid_proxy_security_group].id]
# #   associate_public_ip_address = false
# #   key_name                    = var.squid_proxy_key_pair
# #   user_data                   = file("${path.module}/templates/user_data/squid-stack.sh")
# #   iam_instance_profile        = aws_iam_instance_profile.instance_profile[0].name
# # }

# # resource "aws_autoscaling_group" "squid_proxy_asg" {
# #   count                     = var.create_squid_proxy_asg ? 1 : 0
# #   vpc_zone_identifier       = [aws_subnet.env_subnet[var.proxy_subnet_a].id, aws_subnet.env_subnet[var.proxy_subnet_b].id]
# #   max_size                  = var.squid_proxy_asg_max_size
# #   min_size                  = var.squid_proxy_asg_min_size
# #   health_check_grace_period = 300
# #   health_check_type         = "EC2"
# #   desired_capacity          = var.squid_proxy_asg_desired_capacity
# #   termination_policies      = ["Default"]
# #   launch_configuration      = aws_launch_configuration.squid_proxy_lc[0].name
# #   target_group_arns         = [aws_lb_target_group.squid_proxy_tg[0].arn]
# #   name                      = "${local.name_prefix}-${var.squid_proxy_module_name}-asg"

# #   lifecycle {
# #     create_before_destroy = true
# #   }

# #   tags = concat(
# #     [
# #       {
# #         key                 = "Name"
# #         value               = "${local.name_prefix}-${var.squid_proxy_module_name}-asg"
# #         propagate_at_launch = true
# #       },
# #       {
# #         key                 = "Project"
# #         value               = var.tag_squid_project
# #         propagate_at_launch = true
# #       },
# #       {
# #         key                 = "SquidInstance"
# #         value               = "Yes"
# #         propagate_at_launch = true
# #       },
# #     ],
# #     local.default_list_tags
# #   )
# # }



