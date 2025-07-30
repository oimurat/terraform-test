##########################################################################
# Terraform module: Configuring Private DNS Zones, Views, and Resolvers. #
#                                                                        #
# Copyright (c) 2024 Oracle        Author: Mahamat H. Guiagoussou        #
##########################################################################


terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.18.0"
    }
  }
}


provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}