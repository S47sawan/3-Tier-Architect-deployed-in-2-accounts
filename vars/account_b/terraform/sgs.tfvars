# ======================================================================================================================
# SECURITY GROUPS
# ======================================================================================================================
# =========================================== Instances ================================================================
sgs = {

  wordpress_ec2_sg = {
    "ec2_sg_name_suffix" = "wordpress_ec2_sg"
    "ec2_sg_description" = "Security group to traffic from Application load balancer"
  }
  wordpress_ec2_alb_sg = {
    "ec2_sg_name_suffix" = "wordpress_ec2_alb_sg"
    "ec2_sg_description" = "Security group to allow traffic from public vpc_a"
  }
  memcached_sg = {
    "ec2_sg_name_suffix" = "memcached_sg"
    "ec2_sg_description" = "Security group to allow in-memory data store between web application and memcached cluster"
  }
  aurora_sg = {
    "ec2_sg_name_suffix" = "aurora_sg"
    "ec2_sg_description" = "Security group to allow data transfer between web application and RDS instances"
  }
  env_efs_sg = {
    "ec2_sg_name_suffix" = "env_efs_sg"
    "ec2_sg_description" = "Security group to allow NFS access between Web Application efs"
  }
  "mob_ssm_endpoint_sg" = {
    "ec2_sg_name_suffix" = "mob_ssm_endpoint_sg"
    "ec2_sg_description" = "Security Group to allow communication to SSM endpoint on port 443"
  }
}

# ######################################################################################################################
# INBOUND - TCP, Port Range, CIDR
# ######################################################################################################################
inbound_rules_tcp_sp_cidr = {
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr and sg word press instances
  # --------------------------------------------------------------------------------------------------------------------
  "wordpress_22_cidr" = {
    "port"        = 22
    "description" = "Allow ssh from the bastion host"
    "my_sg"       = "wordpress_ec2_sg"
    "cidr_blocks" = ["10.2.0.29/32"]
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr efs_sg
  # --------------------------------------------------------------------------------------------------------------------
  "efs_sg_2049_cidr_a" = {
    "port"        = 2049
    "description" = "Allow NFS access between Web App and EFS"
    "my_sg"       = "env_efs_sg"
    "cidr_blocks" = ["10.9.0.0/26"]
  }
  "efs_sg_2049_cidr_b" = {
    "port"        = 2049
    "description" = "Allow NFS access between Web App and EFS"
    "my_sg"       = "env_efs_sg"
    "cidr_blocks" = ["10.9.0.64/26"]
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr memcached-sg
  # --------------------------------------------------------------------------------------------------------------------
  "memcached_sg_11211_cidr_a" = {
    "port"        = 11211
    "description" = "Allow in-memory data store between web app and memcached cluster"
    "my_sg"       = "memcached_sg"
    "cidr_blocks" = ["10.9.0.64/26"]
  }
  "memcached_sg_11211_cidr_b" = {
    "port"        = 11211
    "description" = "Allow in-memory data store between web app and memcached cluster"
    "my_sg"       = "memcached_sg"
    "cidr_blocks" = ["10.9.0.0/26"]
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - mob_ssm_endpoint_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_ssm_endpoint_sg_443_cidr" = {
    "port"        = 443
    "description" = "Allow comminucation to ssm endpoints on port 443"
    "my_sg"       = "mob_ssm_endpoint_sg"
    "cidr_blocks" = ["10.2.0.0/16"]
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr aurora-sg
  # --------------------------------------------------------------------------------------------------------------------
  "aurora_sg_3306_cidr_a" = {
    "port"        = 3306
    "description" = "Allow data transfer between web app and RDS instances"
    "my_sg"       = "aurora_sg"
    "cidr_blocks" = ["10.9.0.0/26"]
  }
  "aurora_sg_3306_cidr_b" = {
    "port"        = 3306
    "description" = "Allow data transfer between web app and RDS instances"
    "my_sg"       = "aurora_sg"
    "cidr_blocks" = ["10.9.0.64/26"]
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr wordpressalb
  # --------------------------------------------------------------------------------------------------------------------
  "wordpressalb_443_cidr" = {
    "port"        = 443
    "description" = "Allow traffic from vpc-a"
    "my_sg"       = "wordpress_ec2_alb_sg"
    "cidr_blocks" = ["10.2.0.0/16"]
  }
  "wordpressalb_80_cidr" = {
    "port"        = 80
    "description" = "Allow traffic from vpc-a"
    "my_sg"       = "wordpress_ec2_alb_sg"
    "cidr_blocks" = ["10.2.0.0/16"]
  }
}

# ######################################################################################################################
# INBOUND - TCP, Single Port, Security Group
# ######################################################################################################################
inbound_rules_tcp_sp_sg = {
  "wordpress_80_cidr" = {
    "port"        = 80
    "description" = "Allow traffic from ALB (Applicatio Load Balancer)"
    "my_sg"       = "wordpress_ec2_sg"
    "source_sg"   = "wordpress_ec2_alb_sg"
  }
  "wordpress_443_cidr" = {
    "port"        = 443
    "description" = "Allow traffic from ALB (Applicatio Load Balancer)"
    "my_sg"       = "wordpress_ec2_sg"
    "source_sg"   = "wordpress_ec2_alb_sg"
  }
}
# ######################################################################################################################
# OUTBOUND - TCP, Single Port, CIDR range
# ######################################################################################################################
egress_all = {
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - word press
  # --------------------------------------------------------------------------------------------------------------------
  "wordpress_ec2_egress_all" = {
    "my_sg" = "wordpress_ec2_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - word press alb
  # --------------------------------------------------------------------------------------------------------------------
  "wordpress_ec2_alb_egress_all" = {
    "my_sg" = "wordpress_ec2_alb_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - efs 
  # --------------------------------------------------------------------------------------------------------------------
  "efs_sg_2049_egress_all" = {
    "my_sg" = "env_efs_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - memcache
  # --------------------------------------------------------------------------------------------------------------------
  "memcached_sg_egress_all" = {
    "my_sg" = "memcached_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - aurora
  # --------------------------------------------------------------------------------------------------------------------
  " aurora_sg_egress" = {
    "my_sg" = "aurora_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - mob_ssm_endpoint_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_ssm_endpoint_sg_egress_all" = {
    "my_sg" = "mob_ssm_endpoint_sg"
  }
}
