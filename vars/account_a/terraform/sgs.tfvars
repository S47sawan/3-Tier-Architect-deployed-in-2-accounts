# ======================================================================================================================
# SECURITY GROUPS
# ======================================================================================================================
# =========================================== Instances ================================================================
sgs = {
  "mob_squid_proxy_sg" = {
    "ec2_sg_name_suffix" = "mob_squid_proxy_sg"
    "ec2_sg_description" = "Security Group for squid proxy Instance"
  }
  "mob_bastion_sg" = {
    "ec2_sg_name_suffix" = "mob_bastion_sg"
    "ec2_sg_description" = "Security Group to allow ssh from the internet"
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
  # Ingress tcp_sp_cidr - mob_squid_proxy_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_squid_proxy_sg_80" = {
    "port"        = 80
    "description" = "Allow traffic from net"
    "my_sg"       = "mob_squid_proxy_sg"
    "cidr_blocks" = ["0.0.0.0/0"]
  }
  "mob_squid_proxy_sg_22" = {
    "port"        = 22
    "description" = "Allow ssh access to squid proxy instances via bastion host"
    "my_sg"       = "mob_squid_proxy_sg"
    "cidr_blocks" = ["10.2.0.29/32"]
  }
  "mob_squid_proxy_sg_443" = {
    "port"        = 443
    "description" = "Allow traffic from net"
    "my_sg"       = "mob_squid_proxy_sg"
    "cidr_blocks" = ["0.0.0.0/0"]
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - mob_bastion_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_bastion_sg_22_cidr" = {
    "port"        = 22
    "description" = "Allow ssh from the internet"
    "my_sg"       = "mob_bastion_sg"
    "cidr_blocks" = ["88.111.229.207/32"]
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
}
# ######################################################################################################################
# OUTBOUND - Egress
# ######################################################################################################################
egress_all = {
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - mob_squid_proxy_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_squid_proxy_egress_all" = {
    "my_sg" = "mob_squid_proxy_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - mob_bastion_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_bastion_sg_egress_all" = {
    "my_sg" = "mob_bastion_sg"
  }
  # --------------------------------------------------------------------------------------------------------------------
  # Egress all - mob_ssm_endpoint_sg
  # --------------------------------------------------------------------------------------------------------------------
  "mob_ssm_endpoint_sg_egress_all" = {
    "my_sg" = "mob_ssm_endpoint_sg"
  }
}





