# ===========================================================================================================================
# RESOURCE CLOUDFRONT
# ==========================================================================================================================
#----------------------------------------------------------------------------------------------------------------------------
# Variable
#----------------------------------------------------------------------------------------------------------------------------
variable "lb_distributions" {
  description = "A map of cloudfront distributions"
  default     = {}
}
#----------------------------------------------------------------------------------------------------------------------------
# Create CF resource
#----------------------------------------------------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "lb_distribution" {
  for_each = { for key, value in var.lb_distributions :
    key => value
  if lookup(value, "create_lb_distributions", false) == true }
  enabled         = lookup(each.value, "enabled", false)
  is_ipv6_enabled = lookup(each.value, "is_ipv6_enabled", false)
  comment         = lookup(each.value, "comment", "")
  aliases         = lookup(each.value, "aliases", [])

  # Origins
  dynamic "origin" {
    for_each = lookup(each.value, "origins", {})
    content {
      domain_name = origin.value["domain_name"]
      origin_id   = origin.value["origin_id"]
      custom_origin_config {
        http_port              = origin.value["http_port"]
        https_port             = origin.value["https_port"]
        origin_protocol_policy = origin.value["origin_protocol_policy"]
        origin_ssl_protocols   = origin.value["origin_ssl_protocols"]
      }
    }
  }
  # Default cache behaviour
  default_cache_behavior {
    allowed_methods        = lookup(each.value, "dcb_allowed_methods", [])
    cached_methods         = lookup(each.value, "dcb_cached_methods", [])
    target_origin_id       = lookup(each.value, "dcb_target_origin_id", "")
    compress               = lookup(each.value, "dcb_compress", "")
    viewer_protocol_policy = lookup(each.value, "dcb_viewer_protocol_policy", "")
    min_ttl                = lookup(each.value, "dcb_min_ttl", "")
    default_ttl            = lookup(each.value, "dcb_default_ttl", "")
    max_ttl                = lookup(each.value, "dcb_max_ttl", "")
    forwarded_values {
      query_string = lookup(each.value, "dcb_fv_query_string", "")
      headers      = lookup(each.value, "dcb_fv_headers", "")

      cookies {
        forward           = lookup(each.value, "dcb_c_forward", "")
        whitelisted_names = lookup(each.value, "dcb_c_whitelist", [])
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = lookup(each.value, "geo_restriction_type", "")
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = lookup(each.value, "vc_cloudfront_default_certificate", true)
    acm_certificate_arn            = aws_acm_certificate.cloudfront_certificate[0].arn
    ssl_support_method             = lookup(each.value, "ssl_support_method", "sni-only")
    minimum_protocol_version       = lookup(each.value, "viewer_minimum_protocol_version", null)
  }
  depends_on = [aws_acm_certificate.cloudfront_certificate]
}
