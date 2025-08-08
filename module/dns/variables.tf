# --- リソース作成用の変数 ---

variable "env" {}

variable "compartment_ocid" {}

variable "vcn_id" {}

variable "load_balancer_ocid" {}

variable "public_zone_name" {}

variable "a_records" {}

# 以下はプライベートゾーン作成時
# variable "subnet_id" {}
# variable "forwarding_rules" {}
