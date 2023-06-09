# ======================================================================================================================
# RESOURCE ACM CERTIFICATE
# ======================================================================================================================
# ===================================================================================================================
# VARIABLES
# ==================================================================================================================

variable "tag_cert_name" {
  description = "Name for the certicate"
  default     = ""
}
variable "domain_name" {
  description = "The zone name is the domain name in each of the accounts"
  default     = ""
}
variable "domains" {
  description = "The zone name is the domain name in each of the accounts"
  default     = ""
}
variable "sans" {
  type = string
  description = "These are the alternate domain names"
  default     = ""
}
variable "validation_method" {
  description = "This is the validation mathod that is used for CNAME records"
  default     = ""
}
variable "zone" {
  description = "Used to set the private_zone attribute to either true or false"
  default     = ""
}
variable "create_acm_certficate" {
  description = "Flag used to set enable or disable the creation of acm cert in an environment"
  default     = ""
}
# ===================================================================================================================
# RESOURCE CREATION 
# ===================================================================================================================
# request public certificate from the amazon certificate manager

resource "aws_acm_certificate" "cloudfront_certificate" {
  count                     = var.create_acm_certficate ? 1 : 0
  provider                  = aws.east
  domain_name               = var.domain_name
  subject_alternative_names = [var.sans]
  validation_method         = var.validation_method

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-${var.tag_cert_name}"
    },
  )
}
#------------------------------------------------------------------------------------------------------------------------------------
# get information details about route 53 hosted zone
#------------------------------------------------------------------------------------------------------------------------------------
data "aws_route53_zone" "route53_zone" {
  count        = var.create_acm_certficate ? 1 : 0
  name         = var.domain_name
  private_zone = var.zone
}
#--------------------------------------------------------------------------------------------------------------------------------------
# Create a record set in route s3 for domain validation
#---------------------------------------------------------------------------------------------------------------------------------------

locals {
  dvo = flatten(aws_acm_certificate.cloudfront_certificate.*.domain_validation_options)
}

resource "aws_route53_record" "route53_record" {
  count           = (var.create_acm_certficate ? 1 : 0) * length(var.domains)
  allow_overwrite = true
  name            = lookup(local.dvo[count.index], "resource_record_name")
  records         = [lookup(local.dvo[count.index], "resource_record_value")]
  ttl             = 60
  type            = lookup(local.dvo[count.index], "resource_record_type")
  zone_id         = data.aws_route53_zone.route53_zone[0].zone_id
}
#-------------------------------------------------------------------------------------------------------------------------------------------
# validate acm certificate
#---------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.create_acm_certficate ? 1 : 0 
  provider                = aws.east
  certificate_arn         = aws_acm_certificate.cloudfront_certificate[0].arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}
