# ===================================================================================================================
# GETTING THE NECESSARY VARIABLES FOR THE SECURITY GROUP RULES
# ===================================================================================================================
# ===================================================================================================================
# LOCAL VARIABLES
# ===================================================================================================================
locals {
  vpc_b_cidr = "10.9.0.0/16" # The cidr range for the private vpc B account.
  vpc_a_cidr = "10.2.0.0/16" # The cidr range for the public vpc A account.
  subnets    = merge(var.subnets, var.tgw_subnets)

  user_membership_list = distinct(flatten([for key, value in var.user_details :
    [for group in value.groups :
      { user  = key,
        group = group
      }
    ]
  ]))

  user_membership = { for entry in local.user_membership_list : "${entry.user}.${entry.group}" => entry }
}

