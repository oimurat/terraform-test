# OCIプロバイダの設定
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.12" # 現在使用しているバージョンに合わせて指定
    }
  }
}