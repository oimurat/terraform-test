module "waf" {
  source             = "../../module/waf"
  env                = var.env
  compartment_ocid   = var.compartment_ocid
  load_balancer_ocid = var.load_balancer_ocid
}

module "api-gateway" {
  source           = "../../module/api-gateway"
  env              = var.env
  compartment_ocid = var.compartment_ocid
  subnet_ocid      = var.subnet_ocid
}

module "oke" {
  source                                         = "../../module/oke"
  env                                            = var.env
  compartment_ocid                               = var.compartment_ocid
  vcn_cidr_block                                 = var.vcn_cidr_block
  k8s_api_endpoint_private_subnet_cidr_block     = var.k8s_api_endpoint_private_subnet_cidr_block
  worker_nodes_private_subnet_cidr_block         = var.worker_nodes_private_subnet_cidr_block
  service_loadbalancers_public_subnet_cidr_block = var.service_loadbalancers_public_subnet_cidr_block
  node_pools                                     = var.node_pools
  vcn_id                                         = oci_core_vcn.ec_vcn.id
  k8s_api_endpoint_subnet_id                     = oci_core_subnet.Private-Subnet-For-k8s-API-Endpoint.id
  worker_nodes_private_subnet_id                 = oci_core_subnet.Private-Subnet-For-Worker-Nodes.id
  load_balancers_subnet_id                       = oci_core_subnet.Public-Subnet-For-Load-Balancers.id
}

module "dns" {
  source             = "../../module/dns"
  env                = var.env
  compartment_ocid   = var.compartment_ocid
  vcn_id              = var.vcn_id
  load_balancer_ocid       = var.load_balancer_ocid
  public_zone_name = var.public_zone_name
  a_records                             = var.a_records
}
