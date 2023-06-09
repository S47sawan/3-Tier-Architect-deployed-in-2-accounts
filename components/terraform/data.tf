data "template_file" "workshop_s3_allow_object_policy" {
  template = file("${path.module}/templates/workshop_s3_allow_object_policy.json")
}
data "template_file" "instance_iam_profile_policy" {
  template = file("${path.module}/templates/instance_iam_profile_policy.json")
}
data "template_file" "workshop_s3_deny_delete" {
  template = file("${path.module}/templates/workshop_s3_deny_delete.json")
}
data "template_file" "sns_delivery_policy" {
     template = file("${path.module}/templates/sns_delivery_policy.json")
}