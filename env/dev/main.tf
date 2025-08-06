# module "waf" {
#   source = "../../module/waf"
#   env = var.env
#   compartment_ocid = var.compartment_ocid
#   load_balancer_ocid = var.load_balancer_ocid
# }

# module "api-gateway" {
#   source = "../../module/api-gateway"
#   env = var.env
#   compartment_ocid = var.compartment_ocid
#   subnet_ocid = var.subnet_ocid
# }

# module "oke" {
#   source = "../../module/oke"
#   env = var.env
#   compartment_ocid = var.compartment_ocid
#   vcn_cidr_block = var.vcn_cidr_block
#   k8apiendpoint_private_subnet_cidr_block = var.k8apiendpoint_private_subnet_cidr_block
#   workernodes_private_subnet_cidr_block = var.workernodes_private_subnet_cidr_block
#   serviceloadbalancers_public_subnet_cidr_block = var.serviceloadbalancers_public_subnet_cidr_block
#   node_pools = var.node_pools
# }