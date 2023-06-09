# ======================================================================================================================
# CloudWatch metric alarms and Dashboards
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "create_standard_cw_alarms" {
  type        = bool
  description = "A flag to create CPUUtilization, StatusCheckFailed_Instance, StatusCheckFailed_System and CPUCreditBalance if the instance is of type t"
  default     = false
}

variable "cw_alarms" {
  type        = map(any)
  description = "A map of CloudWatch Alarms and their associated values"
  default     = {}
}

variable "cw_dashboards" {
  type        = map(any)
  description = "A map of CloudWatch Dashboard templates"
  default     = {}
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
resource "aws_cloudwatch_metric_alarm" "env_cw_met_alrm_sns_topic" {
  for_each                  = var.cw_alarms
  alarm_name                = "${local.name_prefix}-${lookup(each.value, "alarm_name", "")}"
  alarm_description         = lookup(each.value, "alarm_description", "")
  comparison_operator       = lookup(each.value, "comparison_operator", "")
  evaluation_periods        = lookup(each.value, "evaluation_periods", "")
  metric_name               = lookup(each.value, "metric_name", "")
  namespace                 = lookup(each.value, "namespace", "")
  period                    = lookup(each.value, "period", "")
  statistic                 = lookup(each.value, "statistic", null)
  threshold                 = lookup(each.value, "threshold", "")

  alarm_actions = compact([
    lookup(each.value, "alarm_actions", "") == "instance_overload" ? aws_sns_topic.env_sns_topic[lookup(each.value, "alarm_actions", "")].arn : lookup(each.value, "alarm_actions_arn", "")
  ])

  dimensions = {
    InstanceId   = aws_instance.instance_standard[lookup(each.value, "dimensions_instance", "")].id
    ImageId      = aws_instance.instance_standard[lookup(each.value, "dimensions_instance", "")].ami
    InstanceType = aws_instance.instance_standard[lookup(each.value, "dimensions_instance", "")].instance_type
  }
}
