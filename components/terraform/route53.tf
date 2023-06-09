# =================================================================================================================================
# RESOURCE : ROUTE 53
# ==================================================================================================================================
# ==================================================================================================================================
# VARIABLES
# ===================================================================================================================================
variable "r53_zones" {
  type        = map(any)
  description = "A map of route 53 zones"
  default     = {}
}
variable "r53_cname_local_efs" {
  type        = map(any)
  description = "A map of cname record addresses for efs"
  default     = {}
}
variable "r53_alias_local_nlb" {
  type        = map(any)
  description = "a map holding record set info for local connections via the network load balancer"
  default     = {}
}
variable "r53_alias_local_alb" {
  type        = map(any)
  description = "a map holding record set info for local connections via the application load balancer"
  default     = {}
}
variable "r53_alias_local_cf" {
  type        = map(any)
  description = "a map holding record set info for local connections for cloudfront distribution"
  default     = {}
}
variable "r53_alias_local_s3" {
  type        = map(any)
  description = "a map holding record set info for local connections for the s3 bucket"
  default     = {}
}
variable "r53_cname_local_db" {
  type        = map(any)
  description = "a map holding record set info for local connections to the database"
  default     = {}
}
variable "r53_cname_local_mem" {
  type        = map(any)
  description = "a map holding record set info for local connections to elasticache memcached"
  default     = {}
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route 53 Zones
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "env_r53_zones" {
  for_each = var.r53_zones
  name     = lookup(each.value, "domain_name", "")
  comment  = "dns-zone"

  tags = (merge(
    local.default_tags
  ))

  dynamic "vpc" {
    for_each = { for key, value in var.r53_zones :
      key => value
    if lookup(value, "private_zone", false) == true }
    content {
      vpc_id = aws_vpc.env_vpc[0].id
    }
  }
}
# ======================================================================================================================
# route 53 routes
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account application load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_alb" {
  for_each = { for key, value in var.r53_alias_local_alb :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_lb.env_alb[lookup(each.value, "alb", "")].dns_name
    zone_id                = aws_lb.env_alb[lookup(each.value, "alb", "")].zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_lb.env_alb]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the cname type record set. local account aurora database
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_cname_local_db" {
  for_each = { for key, value in var.r53_cname_local_db :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id    = aws_route53_zone.env_r53_zones[lookup(each.value, "zone_id", "")].id
  name       = lookup(each.value, "domain_name_prefix", "")
  type       = lookup(each.value, "record_type", "")
  ttl        = lookup(each.value, "ttl", "")
  records    = [aws_rds_cluster_instance.env_aurora_db_instance[each.value.db_ec2].endpoint]
  depends_on = [aws_rds_cluster_instance.env_aurora_db_instance]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the cname type record set. local account memcached cluster
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_cname_local_mem" {
  for_each = { for key, value in var.r53_cname_local_mem :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id    = aws_route53_zone.env_r53_zones[lookup(each.value, "zone_id", "")].id
  name       = lookup(each.value, "domain_name_prefix", "")
  type       = lookup(each.value, "record_type", "")
  ttl        = lookup(each.value, "ttl", "")
  records    = [aws_elasticache_cluster.mem_cluster[lookup(each.value, "mem", "")].configuration_endpoint]
  depends_on = [aws_elasticache_cluster.mem_cluster]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the cname type record set. local account efs
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_cname_local_efs" {
  for_each = { for key, value in var.r53_cname_local_efs :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id    = aws_route53_zone.env_r53_zones[lookup(each.value, "zone_id", "")].id
  name       = lookup(each.value, "domain_name_prefix", "")
  type       = lookup(each.value, "record_type", "")
  ttl        = lookup(each.value, "ttl", "")
  records    = [aws_efs_file_system.env_efs[each.value.efs].dns_name]
  depends_on = [aws_efs_file_system.env_efs]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account network load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_nlb" {
  for_each = { for key, value in var.r53_alias_local_nlb :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_lb.env_lb[each.value.lb_name].dns_name
    zone_id                = aws_lb.env_lb[each.value.lb_name].zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_lb.env_lb]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account cloudfront
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_cf" {
  for_each = { for key, value in var.r53_alias_local_cf :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_cloudfront_distribution.lb_distribution[each.value.lb_distributions].domain_name
    zone_id                = aws_cloudfront_distribution.lb_distribution[each.value.lb_distributions].hosted_zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_cloudfront_distribution.lb_distribution]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account s3 bucket
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_s3" {
  for_each = var.r53_alias_local_s3
  zone_id  = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name     = lookup(each.value, "domain_name_prefix", "")
  type     = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_s3_bucket_website_configuration.s3_website_config[each.value.bucket_name].website_endpoint
    zone_id                = aws_s3_bucket.env_bucket[each.value.bucket_name].hosted_zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_s3_bucket.env_bucket]
}






