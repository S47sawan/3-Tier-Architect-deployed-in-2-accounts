# =================================================================================================================================================================
# Resource RDS Aurora
# =================================================================================================================================================================

# =================================================================================================================================================================
# Variables
# ==================================================================================================================================================================
variable "create_db_subnet_group" {
  description = "This is a flag used to set the deployment of subnet group in different environments"
  default     = ""
}
variable "db_subnet_group" {
  description = "map of subnet group in different environments"
  default     = {}
}
variable "db_subnet_a" {
  description = "subnet for the aurora cluster"
  default     = "pvt_sub_data_01"
}
variable "db_subnet_b" {
  description = "subnet for the aurora cluster"
  default     = "pvt_sub_data_02"
}
variable "create_rds_cluster" {
  description = "This is a flag used to set the deployment of aurora mysql cluster in different environment"
  default     = ""
}
variable "rds_cluster" {
  description = "map of rds cluster created"
  default     = {}
}
variable "db_ec2" {
  description = "Instances used for the database"
  default     = {}
}
variable "create_db_ec2" {
  description = "This is a flag to set deployment of db instances in an env"
  default     = ""
}
variable "mem_cluster" {
  description = "map of memcache clusters "
  default     = {}
}
variable "create_mem_cluster" {
  description = "This is a flag that is used to set creation of memcache clusters in different environments"
  default     = ""
}
variable "elasticache_subnet_group" {
  description = "This is a map of subnet groups for memcache cluster"
  default     = {}
}
variable "create_elasticache_subnet_group" {
  description = "This is a flag that is set to enable deployment of memcache subnets in an environment"
  default     = {}
}
variable "mem_subnet_a" {
  description = "Subnet for deployment of memcache cluster"
  default     = "pvt_sub_data_01"
}
variable "mem_subnet_b" {
  description = "subnet for deployment of memcache cluster"
  default     = "pvt_sub_data_02"
}
# =====================================================================================================================================================================
# RDS subnet group
# ======================================================================================================================================================================
resource "aws_db_subnet_group" "wp_db_sub_grp" {
  for_each    = var.db_subnet_group
  name        = lookup(each.value, "name", "")
  subnet_ids  = [aws_subnet.env_subnet[var.db_subnet_a].id, aws_subnet.env_subnet[var.db_subnet_b].id]
  description = lookup(each.value, "description", "")

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${lookup(each.value, "name", "")}"
      "Owner"   = var.tag_owner
      "Project" = var.tag_project
    },
  )
  depends_on = [aws_subnet.env_subnet]
}
# ===============================================================================================================================================================
# Create Aurora MySQL 2.x (MySQl 5.7)
# ==============================================================================================================================================================
resource "aws_rds_cluster" "env_aurora_cluster" {
  for_each = { for key, value in var.rds_cluster :
    key => value
  if lookup(value, "create_rds_cluster", false) == true }
  cluster_identifier                  = lookup(each.value, "cluster_identifier", "")
  engine                              = lookup(each.value, "engine", "")
  engine_version                      = lookup(each.value, "engine_version", "")
  availability_zones                  = lookup(each.value, "environment_azs", "")
  database_name                       = lookup(each.value, "database_name", "")
  master_username                     = lookup(each.value, "master_username", "")
  master_password                     = lookup(each.value, "master_password", "")
  iam_roles                           = lookup(each.value, "iam_roles", "")
  vpc_security_group_ids              = [for sg in lookup(each.value, "sg_ids", []) : aws_security_group.ec2_sg[sg].id]
  kms_key_id                          = lookup(each.value, "key_id", "")
  iam_database_authentication_enabled = false
  db_cluster_parameter_group_name     = "default.aurora-mysql5.7"
  storage_encrypted                   = true
  backup_retention_period             = 1
  db_subnet_group_name                = lookup(each.value, "db_subnet_group_name", "")
  skip_final_snapshot                 = lookup(each.value, "skip_final_snapshot", "")
  tags = merge(
    local.default_tags,
    {
      "Name" = lookup(each.value, "cluster_identifier", "")
    },
  )
  # For the first apply leave this commented out. After that uncomment and reapply. This will set the az for the 
  lifecycle {
    ignore_changes = [availability_zones]
  }
  depends_on = [aws_db_subnet_group.wp_db_sub_grp]
}
# ============================================================================================================================================================
# Create RDS database instances
# ============================================================================================================================================================
resource "aws_rds_cluster_instance" "env_aurora_db_instance" {
  for_each = { for key, value in var.db_ec2 :
    key => value
  if lookup(value, "create_db_ec2", false) == true }
  identifier              = lookup(each.value, "identifier", "")
  cluster_identifier      = lookup(each.value, "cluster_identifier", "")
  engine                  = lookup(each.value, "engine", "")
  engine_version          = lookup(each.value, "engine_version", "")
  instance_class          = lookup(each.value, "instance_class", "")
  db_parameter_group_name = lookup(each.value, "db_parameter_group_name", "")
  promotion_tier          = lookup(each.value, "promotion_tier", "")
  availability_zone       = lookup(each.value, "availability_zone", "")

  tags = merge(
    local.default_tags,
    {
      "Name" = lookup(each.value, "cluster_identifier", "")
    },
  )
  depends_on = [aws_rds_cluster.env_aurora_cluster]
}
# ===========================================================================================================================================================
# Create memcached subnet group
# =============================================================================================================================================================
resource "aws_elasticache_subnet_group" "mem_subnet_group" {
  for_each = { for key, value in var.elasticache_subnet_group :
    key => value
  if lookup(value, "create_elasticache_subnet_group", false) == true }
  name       = lookup(each.value, "name", "")
  subnet_ids = [aws_subnet.env_subnet[var.mem_subnet_a].id, aws_subnet.env_subnet[var.mem_subnet_b].id]
  # Add second subnet later ,the code is , aws_subnet.env_subnet[var.mem_subnet_b].id
  description = lookup(each.value, "description", "")

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${lookup(each.value, "name", "")}"
      "Owner"   = var.tag_owner
      "Project" = var.tag_project
    },
  )
}
# ===========================================================================================================================================================
# Create memcached cluster
# =============================================================================================================================================================
resource "aws_elasticache_cluster" "mem_cluster" {
  for_each = { for key, value in var.mem_cluster :
    key => value
  if lookup(value, "create_mem_cluster", false) == true }
  subnet_group_name            = lookup(each.value, "subnet_group_name", "")
  cluster_id                   = lookup(each.value, "cluster_id", "")
  engine                       = lookup(each.value, "engine", "")
  node_type                    = lookup(each.value, "node_type", "")
  num_cache_nodes              = lookup(each.value, "num_cache_nodes", "")
  parameter_group_name         = lookup(each.value, "parameter_group_name", "")
  port                         = lookup(each.value, "port", "")
  engine_version               = lookup(each.value, "engine_version", "")
  preferred_availability_zones = lookup(each.value, "preferred_availability_zone", "")
  security_group_ids           = [for sg in lookup(each.value, "sg_ids", []) : aws_security_group.ec2_sg[sg].id]

  tags = merge(
    local.default_tags,
    {
      "Name"    = lookup(each.value, "subnet_group_name", "")
      "Owner"   = var.tag_owner
      "Project" = var.tag_project
    },
  )
}
