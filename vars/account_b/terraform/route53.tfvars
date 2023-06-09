# ======================================================================================================================
# route 53 variables
# ======================================================================================================================
r53_zones = {
  "internal.mobilise.academy" = {
    create_acm_cert = false
    domain_name      = "internal.mobilise.academy"
    private_zone     = true
  }
}

r53_alias_local_alb = {
  "wp-lb" = {
    "create_record"          = true
    "zone"                   = "internal.mobilise.academy"
    "domain_name_prefix"     = "wp-lb"
    "alb"                    = "wordpress-alb"
    "record_type"            = "A"
    "evaluate_target_health" = false
  }
}
r53_cname_local_db = {
  "database" = {
    "create_record"      = true
    "zone_id"            = "internal.mobilise.academy"
    "domain_name_prefix" = "database"
    "record_type"        = "CNAME"
    "ttl"                = "300"
    "db_ec2"             = "wp_cluster_instance_01"
  }
}
r53_cname_local_mem = {
  "cache" = {
    "create_record"      = true
    "zone_id"            = "internal.mobilise.academy"
    "domain_name_prefix" = "cache"
    "record_type"        = "CNAME"
    "ttl"                = "300"
    "mem"                = "mem_cluster_01"
  }
}
r53_cname_local_efs = {
  "storage" = {
    "create_record"      = false
    "zone_id"            = "internal.mobilise.academy"
    "domain_name_prefix" = "storage"
    "record_type"        = "CNAME"
    "ttl"                = "300"
    "efs"                = "env_efs_01"
  }
}

