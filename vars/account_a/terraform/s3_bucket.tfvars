# ======================================================================================================================
# Configuration for creating S3 buckets, roles for those buckets and any policies to attach
# =====================================================================================================================
s3_buckets = {
  "assets_ssa_mobilise" = {
    create_bucket           = true
    bucket_name             = "assets.ssa.mobilise.academy"
    bucket_acl              = "BucketOwnerEnforced"
    bucket_versioning       = "Enabled"
    bucket_force_destroy    = false
    sse_algorithm           = "AES256"
    s3_bucket_object_key    = "ShoppingList.txt"
    s3_bucket_object_source = "/Users/smihah/Downloads/ShoppingList.txt"

    # Tags
    tag_project = "Mobilise-Workshop"
    tag_owner   = "Mobilise"
    # Public access
    allow_public_access = true

  }
}

