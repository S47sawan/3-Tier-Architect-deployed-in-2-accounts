# --------------------------------------------------------------------------------------------------------------------
# CloudFront Variables
# --------------------------------------------------------------------------------------------------------------------
lb_distributions = {
  "mob_academy_cf" = {
    # General settings
    create_lb_distributions = true
    enabled                 = true
    is_ipv6_enabled         = true
    comment                 = "cloudfront-distribution-for-wordpress"
    aliases                 = ["www.ssa.mobilise.academy"]

    # Origins
    origins = {
      "origin_01" = {
        "domain_name"            = "www-lb.ssa.mobilise.academy"
        "origin_id"              = "www-lb.ssa.mobilise.academy"
        "http_port"              = 80
        "https_port"             = 443
        "origin_protocol_policy" = "http-only"
        "origin_ssl_protocols"   = ["TLSv1.2"]
      }
    }

    # Default cache behaviour
    dcb_allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    dcb_cached_methods         = ["GET", "HEAD", "OPTIONS"]
    dcb_target_origin_id       = "www-lb.ssa.mobilise.academy"
    dcb_compress               = true
    dcb_viewer_protocol_policy = "redirect-to-https"
    dcb_min_ttl                = 0
    dcb_default_ttl            = 300
    dcb_max_ttl                = 31536000
    dcb_fv_query_string        = true
    dcb_fv_headers             = ["Origin", "Host"]
    dcb_c_forward              = "whitelist"
    dcb_c_whitelist            = ["comment_author_*", "comment_author_email_*", "comment_author_url_*", "wordpress_*", "wordpress_logged_in_*", "wordpress_test_cookie", "wp-settings-*"]
    geo_restriction_type       = "none"

    vc_cloudfront_default_certificate = false
    acm_certificate_arn               = "mobilise_academy_sa_cert"
    ssl_support_method                = "sni-only"
    viewer_minimum_protocol_version   = "TLSv1.2_2021"
  }
}
