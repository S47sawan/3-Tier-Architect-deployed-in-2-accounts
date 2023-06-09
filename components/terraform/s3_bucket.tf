#=======================================================================================================
# VARIABLES
#=======================================================================================================
variable "s3_buckets" {
  description = "A map of details for a set of S3 buckets"
  default     = {}
}
#======================================================================================================
# S3 Bucket Resources
#=======================================================================================================
#-------------------------------------------------------------------------------------------------------
# Create an S3 bucket
#-------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "env_bucket" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "create_bucket", false) == true }
  bucket        = lookup(each.value, "bucket_name", "")
  force_destroy = lookup(each.value, "bucket_force_destroy", true)

  tags = merge(
    local.default_tags,
    {
      "Name"    = lookup(each.value, "bucket_name", "")
      "Project" = lookup(each.value, "tag_project", "")
    }
  )
  lifecycle {
    ignore_changes = [
      tags["Name"], tags["project"], lifecycle_rule, server_side_encryption_configuration,
      acl, website
    ]
  }
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------
# Create s3 bucket versioning
#--------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "versioning_s3" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "create_bucket", false) == true }
  bucket = aws_s3_bucket.env_bucket[each.key].id
  versioning_configuration {
    status = lookup(each.value, "bucket_versioning", "")
  }
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
#Create s3 acl 
#-------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "s3_acl" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "create_bucket", false) == true }
  # for_each = var.s3_buckets
  bucket = aws_s3_bucket.env_bucket[each.key].id
  rule {
    object_ownership = lookup(each.value, "bucket_acl", "")
  }
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Create s3 server side encryption
#-------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse_config" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "create_bucket", false) == true }
  bucket = aws_s3_bucket.env_bucket[each.key].id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = lookup(each.value, "sse_algorithm", "")
    }
  }
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Create Public Access Configuration for the s3 bucket
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "allow_public_access", false) == true }
  bucket              = aws_s3_bucket.env_bucket[each.key].id
  block_public_acls   = false
  block_public_policy = false
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Create static hosting of website
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_website_configuration" "s3_website_config" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "create_bucket", true) == true }
  # for_each = var.s3_buckets
  bucket = aws_s3_bucket.env_bucket[each.key].id
  redirect_all_requests_to {
    host_name = "https://assets.ssa.mobilise.academy.s3-website.eu-west-2.amazonaws.com/"
    protocol  = "https"
  }
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------
# Attach policies for the s3 bucket. Allow access of object in s3 bucket
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "allow_access_to_s3_bucket_object" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "allow_public_access", false) == true }
  bucket = aws_s3_bucket.env_bucket[each.key].id
  policy = data.template_file.workshop_s3_allow_object_policy.rendered
}
# -------------------------------------------------------------------------------------------------------------------------
# s3 bucket object
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "assets_object" {
  for_each = { for key, value in var.s3_buckets :
    key => value
  if lookup(value, "create_bucket", false) == true }
  # for_each     = var.create_bucket == true ? 1 : 0
  bucket     = lookup(each.value, "bucket_name", "")
  key        = lookup(each.value, "s3_bucket_object_key", "")
  source     = lookup(each.value, "s3_bucket_object_source", "")
  depends_on = [aws_s3_bucket.env_bucket]
}

