# Terraform自体の設定
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.12"
    }
  }
}

# OCIプロバイダの設定
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}
