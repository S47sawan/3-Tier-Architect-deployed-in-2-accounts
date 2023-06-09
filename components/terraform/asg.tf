# ======================================================================================================================
# Variables
# ======================================================================================================================
variable "launch_template" {
  description = "Launch template used to create the wordpress Instances"
  default = ""
}
variable "wp_asg" {
   description = ""
   default = ""
}
variable "wordpress_instance_count" {
    description = "The number of instances required for desired capacity as well as min and max"
    default = ""
}
variable "wp_subnet_a" {
  description = "subnet for the aurora cluster"
  default     = "pvt_sub_data_01"
}
variable "wp_subnet_b" {
  description = "subnet for the aurora cluster"
  default     = "pvt_sub_data_02"
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Wordpress - Launch Template
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "wordpress_lt" {
  for_each = { for key, value in var.launch_template :
    key => value
  if lookup(value,"create_wp_lt", false) == true }
  name                   = each.value.name
  instance_type          = each.value.wp_instance_type
  image_id               = each.value.wp_ami_id
  key_name               = each.value.key_name
  vpc_security_group_ids = [for sg in lookup(each.value, "sg_id", []) : aws_security_group.ec2_sg[sg].id]

  tags = merge(
    local.default_tags,
    {
      "Name"  = each.value.name
      "Owner" =  var.tag_owner
      "Project" = var.tag_project
    }  
  )
    tag_specifications {
    resource_type = "instance"

    tags = merge(
    local.default_tags,
    {
      "Name"  = "${local.name_prefix}-wordpress-ec2"
      "Owner" = var.tag_owner
    }  
  )
  }
    tag_specifications {
    resource_type = "volume"

    tags = merge(
    local.default_tags,
    {
      "Name"  = "${local.name_prefix}-wordpress-ebs"
      "Owner" = var.tag_owner
    }  
   )
 }
 depends_on = [aws_ami_from_instance.mob_wordpress_ami]
}
# ----------------------------------------------------------------------------------------------------------------------
# Wordpress - Auto Scaling Group
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "wordpress_asg" {
  for_each = { for key, value in var.wp_asg :
    key => value
  if lookup(value, "create_wp_asg", false) == true }
  vpc_zone_identifier       = [aws_subnet.env_subnet[each.value.wp_subnet_a].id, aws_subnet.env_subnet[each.value.wp_subnet_b].id]
  name                      = each.value.name
  health_check_type         = each.value.health_check_type
  desired_capacity          = each.value.desired_ec2 
  max_size                  = each.value.max_ec2
  min_size                  = each.value.min_ec2
  health_check_grace_period = each.value.hcgp
  
  launch_template {
    id      = aws_launch_template.wordpress_lt[lookup(each.value, "lt_resource_name", "")].id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.wordpress_lt]

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  tags = concat(
  [
  {
    key     = "Name"
    value   = "${local.name_prefix}-${lookup(each.value, "name", "")}"
    propagate_at_launch = true
  },
 {
    key     = "Owner"
    value   = var.tag_owner
    propagate_at_launch = true
  },
 {
    key     = "Project"
    value   = var.tag_project
    propagate_at_launch = true
  },
],
local.default_list_tags
)
}
#--------------------------------------------------------------------------------------------------------------------------
# Create a NLB Target Group attachment
#-------------------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_attachment" "wordpress_tg_attachment" {
  for_each = { for key, value in var.wp_asg :
    key => value
  if lookup(value, "create_wp_asg", false) == true }
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg[each.key].id
  alb_target_group_arn   = aws_lb_target_group.env_alb_tg[lookup(each.value, "alb_target_group_resource_name", "")].arn 

  depends_on             = [aws_lb_target_group.env_alb_tg]
}