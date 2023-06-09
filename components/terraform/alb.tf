# ======================================================================================================================
# APPLICATION LOAB BALANCER FOR THE WORDPRESS IN ACCOUNT B
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "albs" {
  description = "A map of application load balancers"
  default     = {}
}
variable "alb_listeners" {
  description = "A map of all listeners that forward traffic to the wordpress instances in the app 01 and app 02 subnets in account b"
  default     = {}
}
variable "alb_target_grps" {
  description = "A map of all the target groups created"
  default     = {}
}
variable "alb_targets" {
  description = "A map of all targets to assign to a target group"
  default     = {}
}
# ----------------------------------------------------------------------------------------------------------------------
# Create Application load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "env_alb" {
  for_each = { for key, value in var.albs :
    key => value
  if lookup(value, "create_albs", false) == true }
  #for_each           = var.albs
  name               = each.key
  internal           = each.value.internal
  load_balancer_type = each.value.lb_type
  security_groups    = [aws_security_group.ec2_sg[each.value.sg_id].id]
  subnets            = [aws_subnet.env_subnet[each.value.wp_subnet_a].id, aws_subnet.env_subnet[each.value.wp_subnet_b].id]

  enable_deletion_protection = false
     #Change this to TRUE after application
  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-${each.key}"
    }
  )
}
# ----------------------------------------------------------------------------------------------------------------------
#  Create Target Groups
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "env_alb_tg" {
  for_each    = var.alb_target_grps
  name        = "${local.name_prefix}-${lookup(each.value, "tg_name", "")}"
  port        = lookup(each.value, "tg_port", "")
  protocol    = lookup(each.value, "tg_protocol", "")
  target_type = lookup(each.value, "tg_type", "")
  vpc_id      = aws_vpc.env_vpc[0].id
  stickiness {
    type            = "lb_cookie"
    enabled         = lookup(each.value, "stickiness", false)
    cookie_duration = lookup(each.value, "cookie_duration", 86400)
  }
  health_check {
    healthy_threshold   = lookup(each.value, "healthy_threshold", "")
    unhealthy_threshold = lookup(each.value, "unhealthy_threshold", "")
    timeout             = lookup(each.value, "hc_timeout", "")
    interval            = lookup(each.value, "hc_interval", "")
    protocol            = lookup(each.value, "hc_protocol", "")
    port                = lookup(each.value, "hc_port", "")
    path                = lookup(each.value, "hc_path", "")
    matcher             = lookup(each.value, "success_codes", "")

  }
  depends_on = [aws_lb.env_alb]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Listeners
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "alb_listener" {
  for_each = { for key, value in var.alb_listeners :
    key => value
  if lookup(value, "create_alb_listener", false) == true }
  #for_each          = var.alb_listeners
  load_balancer_arn = aws_lb.env_alb[lookup(each.value, "alb", "")].arn
  port              = lookup(each.value, "port", "")
  protocol          = lookup(each.value, "protocol", "")

  default_action {
    type             = lookup(each.value, "alb_action", "")
    target_group_arn = aws_lb_target_group.env_alb_tg[lookup(each.value, "alb_target_group_resource_name", "")].arn
  }
  depends_on = [aws_lb_target_group.env_alb_tg]
}
# ----------------------------------------------------------------------------------------------------------------------
# Create ALB targets
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "env_alb_target_group_attach" {
  for_each = { for key, value in var.alb_targets :
    key => value
  if lookup(value, "add_alb_targets", false) == true }
  target_group_arn = aws_lb_target_group.env_alb_tg[lookup(each.value, "alb_target_group_resource_name", "")].arn
  target_id        = aws_instance.instance_standard[lookup(each.value, "alb_target_resource_name", "")].id

  depends_on = [aws_instance.instance_standard]
}


