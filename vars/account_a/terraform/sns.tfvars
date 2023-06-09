# ======================================================================================================================
# Simple Notification Service (SNS) variables
# ======================================================================================================================
sns_topics = {
  "instance_overload" = {
    "topic_name"         = "instance-overload"
    "topic_subscription" = true
    "display_name"       = "sns-topic-for-breached-instance-metric-alarms"
    "sns_email_address"  = "smihah.awan@mobilise.cloud"
    "access_pol_req"     = true
    "access_pol_file"    = "sns_access_backup_policy.json"
    "tag_owner"          = "mobilise-academy-ssa"
  }
}
