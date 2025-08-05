# --- リソース作成用の変数 ---

variable "env" {}

variable "compartment_ocid" {}

variable "vcn_cidr_block" {}

variable "k8apiendpoint_private_subnet_cidr_block" {}

variable "workernodes_private_subnet_cidr_block" {}

variable "serviceloadbalancers_public_subnet_cidr_block" {}

variable "node_pools" {}