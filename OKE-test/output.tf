##########################################################################
# Terraform module: Configuring Private DNS Zones, Views, and Resolvers. #
#                                                                        #
# Copyright (c) 2025 Oracle        Author: Mahamat H. Guiagoussou        #
##########################################################################


# Working Compartment 
output "compartment_id" {
  value = var.compartment_id
}

# Bastion Instance Image OCID
output "image_ids" {
  value = var.image_ids[var.region]
}


# Display Name Prefix
output "display_name_prefix" {
  value = var.display_name_prefix
}


# Host Name Prefix
output "host_name_prefix" {
  value = var.host_name_prefix
}


# VCN and Subnets OCID


# VCN OCID
output "vcn_ocid" {
  value = oci_core_vcn.this.*.id
}


# OKE API End Point Private Subnet OCID
output "Private-K8-API-Endpoint-Subnet_OCID" {
  value = oci_core_subnet.Private-Subnet-For-K8-API-Endpoint.*.id
}


# Worker Nodes Private-Subnet OCID
output "Private-Subnet-For-Worker-Nodes_OCID" {
  value = oci_core_subnet.Private-Subnet-For-Worker-Nodes.*.id
}


# LoadBalancer Public Subnet OCID  
output "Public-Subnet-For-LoadBalancer_OCID" {
  value = oci_core_subnet.Public-Subnet-For-Load-Balancers.*.id
}


# OKE Cluster and Node Pool Output

# OKE Cluster OCID
output "oke_cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.*.id
}

# OKE Cluster Display Name
output "oke_cluster_display_name" {
  value = oci_containerengine_cluster.oke_cluster.*.name
}

# OKE Cluster Detailed 
output "oke_cluster_ip_addresses" {
  value = one(oci_containerengine_cluster.oke_cluster.*.endpoints)
}


output "node_pool_information" {
  value = { for node_pool_key, node_pool_attributes in oci_containerengine_node_pool.node_pool_one : node_pool_key => node_pool_attributes.nodes }
}
