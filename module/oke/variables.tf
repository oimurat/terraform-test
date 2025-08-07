# --- リソース作成用の変数 ---

variable "env" {}

variable "compartment_ocid" {}

variable "vcn_cidr_block" {}

variable "k8s_api_endpoint_private_subnet_cidr_block" {}

variable "worker_nodes_private_subnet_cidr_block" {}

variable "service_loadbalancers_public_subnet_cidr_block" {}

variable "node_pools" {}

variable "vcn_id" {}

variable "k8s_api_endpoint_subnet_id" {}

variable "worker_nodes_private_subnet_id" {}

variable "load_balancers_subnet_id" {}
