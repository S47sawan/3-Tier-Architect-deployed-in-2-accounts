# ======================================================================================================================
# route 53 variables
# ======================================================================================================================
r53_zones = {
  "ssa.mobilise.academy" = {
    create_acm_cert  = true
    domain_name      = "ssa.mobilise.academy"
    private_zone     = false
    comment          = "public-zone"
  }
}
r53_alias_local_s3 = {
  "assets" = {
    "create_record"          = true
    "zone"                   = "ssa.mobilise.academy"
    "domain_name_prefix"     = "assets"
    "record_type"            = "A"
    "evaluate_target_health" = false
    "bucket_name"            = "assets_ssa_mobilise"
  }
}

r53_alias_local_nlb = {
  "www-lb" = {
   "create_record"          = true
    "zone"                   = "ssa.mobilise.academy"
    "domain_name_prefix"     = "www-lb"
    "lb_name"                = "squid_proxy_lb"
    "record_type"            = "A"
    "evaluate_target_health" = false
  }
}
r53_alias_local_cf = {
  "www" = {
    "create_record"          = true
    "zone"                   = "ssa.mobilise.academy"
    "domain_name_prefix"     = "www"
    "lb_distributions"       = "mob_academy_cf"
    "record_type"            = "A"
    "evaluate_target_health" = false

  }
}


