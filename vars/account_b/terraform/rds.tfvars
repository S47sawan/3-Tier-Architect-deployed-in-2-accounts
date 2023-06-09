# -------------------------------------------------------------------------------------------------------------------
# Aurora Database Cluster for Wordpress DB
# -------------------------------------------------------------------------------------------------------------------
rds_cluster = {
  "aurora_cluster_01" = {
    cluster_identifier     = "aurora-cluster-01"
    engine                 = "aurora-mysql"
    engine_version         = "5.7.mysql_aurora.2.10.2"
    database_name          = "wp_database"
    create_db_subnet_group = true
    create_rds_cluster     = true
    db_subnet_a            = "pvt_sub_data_01"
    db_subnet_b            = "pvt_sub_data_02"
    db_subnet_group_name   = "wp-db-sub-grp"
    master_username        = "academy_admin"
    master_password        = "Mobilise_Academy123"
    environment_azs        = ["eu-west-2a", "eu-west-2b"]
    sg_ids                 = ["aurora_sg"]
    iam_roles              = ["arn:aws:iam::679749876012:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"]
    key_id                 = "arn:aws:kms:eu-west-2:679749876012:key/ee46a35b-92b9-4833-8e52-1edd2c88eb94"
    skip_final_snapshot    = true
  }
}
# -------------------------------------------------------------------------------------------------------------------
# Database Subnet Groups
# -------------------------------------------------------------------------------------------------------------------
db_subnet_group = {
  wp_db_sub_grp = {
    create_db_subnet_group = true
    name                   = "wp-db-sub-grp"
    description            = "subnet group for aurora db cluster"
  }
}
# -------------------------------------------------------------------------------------------------------------------
# Database Instance cluster
# ----------------------------------------------------------------------------------------------------------------------
db_ec2 = {
  "wp_cluster_instance_01" = {
    create_db_ec2           = true
    identifier              = "wp-cluster-instance-01"
    cluster_identifier      = "aurora-cluster-01"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.10.2"
    instance_class          = "db.t3.small"
    db_parameter_group_name = "default.aurora-mysql5.7"
    promotion_tier          = "1"
    environment_azs         = "eu-west-2a"
  }
  "wp_cluster_instance_02" = {
    create_db_ec2           = true
    identifier              = "wp-cluster-instance-02"
    cluster_identifier      = "aurora-cluster-01"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.10.2"
    instance_class          = "db.t3.small"
    db_parameter_group_name = "default.aurora-mysql5.7"
    promotion_tier          = "0"
    environment_azs         = "eu-west-2b"

  }
}
#--------------------------------------------------------------------------------------------------
# memcache variables
#-----------------------------------------------------------------------------------------------------
mem_cluster = {
  "mem_cluster_01" = {
    create_mem_cluster          = true
    subnet_group_name           = "mem-subnet-group-01"
    cluster_id                  = "memcached-cluster-01"
    engine                      = "memcached"
    node_type                   = "cache.t2.micro"
    num_cache_nodes             = "2"
    parameter_group_name        = "default.memcached1.6"
    port                        = 11211
    engine_version              = "1.6.12"
    preferred_availability_zone = ["eu-west-2a", "eu-west-2b"]
    security_group_ids          = ["memcached_sg"]
  }
}
elasticache_subnet_group = {
  "mem-subnet-group-01" = {
    create_elasticache_subnet_group = true
    name                            = "mem-subnet-group-01"
    subnet_ids                      = ["pvt_sub_data_01", "pvt_sub_data_02"]
    description                     = "Subnet group for memcached cluster"
    mem_subnet_a                    = "pvt_sub_data_01"
    mem_subnet_b                    = "pvt_sub_data_02"
  }
}






