# ======================================================================================================================
# Simple Notification Service (SNS) resources
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "sns_topics" {
  description = "A map of sns topics"
  default     = {}
}

# ======================================================================================================================
# RESOURCES
# ======================================================================================================================
resource "aws_sns_topic" "env_sns_topic" {
  for_each        = var.sns_topics
  name            = "${local.name_prefix}-${lookup(each.value, "topic_name", "")}-alerts"
  display_name    = lookup(each.value, "display_name", "")
  delivery_policy = data.template_file.sns_delivery_policy.rendered
  tags = merge(
    local.default_tags,
    {
      "Name"  = "${local.name_prefix}-${lookup(each.value, "topic_name", "")}-alerts"
      "Owner" = lookup(each.value, "tag_owner", "")
    },
  )
}

resource "aws_sns_topic_subscription" "env_email_subscriptions" {
  for_each = {
    for key, value in var.sns_topics : key => value
    if lookup(value, "topic_subscription", false) == true
  }
  topic_arn  = aws_sns_topic.env_sns_topic[each.key].arn
  protocol   = "email"
  endpoint   = lookup(each.value, "sns_email_address", "")
  depends_on = [aws_sns_topic.env_sns_topic]
}

resource "aws_sns_topic_policy" "env_sns_access_policy" {
  for_each = { for key, value in var.sns_topics :
    key => value
  if lookup(value, "access_pol_req", false) == true }
  arn = aws_sns_topic.env_sns_topic[each.key].arn
  policy = templatefile("${path.module}/templates/${each.value.access_pol_file}", {
    source_arn = aws_sns_topic.env_sns_topic[each.key].arn
    account_no = var.account_no
  })
}
