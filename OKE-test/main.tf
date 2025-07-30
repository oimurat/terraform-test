
####################################################################################
# Terraform module: Oracle Kubernetes Engine Flat Module (Adapted).     	   #
#                                                                        	   #
# Copyright (c) 2025 Oracle        Author: Mahamat H. Guiagoussou and Payal Sharma #
####################################################################################


# OKE Cluster
resource "oci_containerengine_cluster" "k8s_cluster" {
  count = (var.is_k8cluster_created) ? 1 : 0

  #Required
  compartment_id     = var.compartment_id
  kubernetes_version = var.control_plane_kubernetes_version
  name               = "${var.display_name_prefix}-k8s-Cluster"
  vcn_id             = oci_core_vcn.this.*.id[0]

  #Optional
  cluster_pod_network_options {
    #Required
    cni_type = var.cni_type
  }


  endpoint_config {
    #Optional
    is_public_ip_enabled = var.control_plane_is_public
    subnet_id            = oci_core_subnet.Private-Subnet-For-K8-API-Endpoint.*.id[0]
  }


  image_policy_config {
    #Optional
    is_policy_enabled = var.image_signing_enabled
    dynamic "key_details" {
      for_each = var.image_signing_enabled == true ? toset(var.image_signing_key_id) : []
      content {
        kms_key_id = var.image_signing_key_id.value
        # Optional - Include if you want to use your own encryption key for image signing, else it's encrypted using Oracle-managed keys
        # kms_key_id = oci_kms_key.test_key.id
      }
    }
  }
  # Optional - use if you want to bring your own encryption key for k8 secrets, else it's encrypted using Oracle-managed keys
  # kms_key_id = oci_kms_key.test_key.id


  options {

    #Optional
    add_ons { # https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengintroducingclusteraddons.htm or OCI CLI command: oci ce addon-option list --kubernetes-version v1.30.1
      #Optional
      is_kubernetes_dashboard_enabled = false
    }

    kubernetes_network_config {
      #Optional
      pods_cidr     = "10.244.0.0/16" # CNI-assigned IP range
      services_cidr = "10.96.0.0/16"  # IP range for ClusterIP services
    }
    
    # This block is used to assign default tags to the PVCs, these can be overwritten by the storage class. 
    persistent_volume_config {
      #Optional
      # defined_tags = {"Operations.CostCenter"= "42"}
      # freeform_tags = {"Department"= "Finance"}
    }
    # Uses to assign default tags to load balancers provisioned by services of type LoadBalancer
    service_lb_config {

    }
    # OCID of subnet where load balancers will reside.
    service_lb_subnet_ids = oci_core_subnet.Public-Subnet-For-Load-Balancers.*.id
    
  }
  type = var.cluster_type #ENHANCED_CLUSTER or BASIC_CLUSTER
}



# Node Pool
resource "oci_containerengine_node_pool" "node_pool_one" {
  depends_on = [oci_containerengine_cluster.k8s_cluster]

  for_each = (var.is_nodepool_created) ? var.node_pools : {}

  #Required
  cluster_id     = oci_containerengine_cluster.k8s_cluster.*.id[0]
  compartment_id = var.compartment_id
  name           = var.node_pools[each.key].name
  node_shape     = var.node_pools[each.key].shape

  dynamic "initial_node_labels" {
    for_each = var.node_pools[each.key].node_labels
    content {
      #Optional
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }

  kubernetes_version = var.worker_nodes_kubernetes_version
  
  node_config_details {
    #Required
    dynamic "placement_configs" {
      for_each = var.node_pools[each.key].availability_domains
      content {
        #Required
        availability_domain = placement_configs.value
        subnet_id           = oci_core_subnet.Private-Subnet-For-Worker-Nodes.*.id[0]
      }
    }
    
    size = var.node_pools[each.key].number_of_nodes

    #Optional
    is_pv_encryption_in_transit_enabled = var.node_pools[each.key].pv_in_transit_encryption
    node_pool_pod_network_option_details {
      #Required
      cni_type = var.cni_type
        # ADD THIS for VCN-Native CNI
      pod_subnet_ids = var.create_pod_network_subnet ? [oci_core_subnet.Private-Subnet-For-Worker-Nodes.*.id[0]] : [ ]
    }
  }

  # node_eviction_node_pool_settings {
  #     #Optional
  #     eviction_grace_duration = var.node_pool_node_eviction_node_pool_settings_eviction_grace_duration
  #     is_force_delete_after_grace_duration = var.node_pool_node_eviction_node_pool_settings_is_force_delete_after_grace_duration
  # }
  node_pool_cycling_details {
    #Optional
    is_node_cycling_enabled = var.node_pools[each.key].node_cycle_config.node_cycling_enabled
    maximum_surge           = var.node_pools[each.key].node_cycle_config.maximum_surge
    maximum_unavailable     = var.node_pools[each.key].node_cycle_config.maximum_unavailable
  }

  node_shape_config {
    #Optional
    memory_in_gbs = var.node_pools[each.key].shape_config.memory
    ocpus         = var.node_pools[each.key].shape_config.ocpus
  }

  node_source_details {
    #Required
    image_id    = var.node_pools[each.key].image
    source_type = "IMAGE"
    #Optional
    boot_volume_size_in_gbs = var.node_pools[each.key].boot_volume_size
  }
  ssh_public_key = file(var.node_pools[each.key].ssh_key)
}
