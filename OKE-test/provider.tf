terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 7.11" # または、特定の要件がある場合はより厳密なバージョンを指定
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key_path = var.private_key_path
  region       = var.region
}