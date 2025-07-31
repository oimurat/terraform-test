
####################################################################################
# Terraform module: Oracle Kubernetes Engine Flat Module (Adapted).     	   #
#                                                                        	   #
# Copyright (c) 2025 Oracle        Author: Mahamat H. Guiagoussou and Payal Sharma #
####################################################################################

# OKE Cluster
resource "oci_containerengine_cluster" "oke_cluster" {
  count = var.is_k8cluster_created ? 1 : 0

  compartment_id     = var.compartment_id
  kubernetes_version = var.control_plane_kubernetes_version
  name               = "${var.display_name_prefix}-k8s-Cluster"
  vcn_id             = oci_core_vcn.this[0].id

  endpoint_config {
    is_public_ip_enabled = var.control_plane_is_public
    subnet_id            = oci_core_subnet.Private-Subnet-For-K8-API-Endpoint[0].id # ★プライベートサブネットを指定
  }
  
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [oci_core_subnet.Public-Subnet-For-Load-Balancers[0].id]
  }
  type = "ENHANCED_CLUSTER"
}

# Availability Domain Data Source
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

# Node Pool
resource "oci_containerengine_node_pool" "node_pool_one" {
  depends_on = [oci_containerengine_cluster.oke_cluster]
  for_each   = var.is_nodepool_created ? var.node_pools : {}

  cluster_id       = oci_containerengine_cluster.oke_cluster[0].id
  compartment_id   = var.compartment_id
  name             = each.value.name
  node_shape       = each.value.shape
  kubernetes_version = var.worker_nodes_kubernetes_version

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
      subnet_id           = oci_core_subnet.Private-Subnet-For-Worker-Nodes[0].id
    }
    size = each.value.number_of_nodes
  }

  node_shape_config {
    ocpus         = each.value.shape_config.ocpus
    memory_in_gbs = each.value.shape_config.memory
  }

  node_source_details {
    image_id    = each.value.image
    source_type = "IMAGE"
    boot_volume_size_in_gbs = each.value.boot_volume_size
  }
  ssh_public_key = each.value.ssh_key
  #ssh_public_key = file(each.value.ssh_key)
  #ssh公開鍵貼り付けで検証
  #要修正
}
