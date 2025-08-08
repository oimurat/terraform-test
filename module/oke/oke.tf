# OKEクラスタを作成
resource "oci_containerengine_cluster" "oke_cluster" {

  compartment_id     = var.compartment_ocid
  kubernetes_version = "v1.33.1"
  name               = "${var.env}-cluster"
  vcn_id             = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = var.k8s_api_endpoint_subnet_id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
    }
    kubernetes_network_config {
      services_cidr = "10.96.1.0/16"
    }
    service_lb_subnet_ids = [var.load_balancers_subnet_id]
  }
  type = "ENHANCED_CLUSTER"
}

# Availability Domainを取得
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_ocid
}

# Node Poolを作成
resource "oci_containerengine_node_pool" "node_pool_one" {
  depends_on = [oci_containerengine_cluster.oke_cluster]
  for_each   = var.node_pools

  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  name               = "${var.env}-node-pool"
  node_shape         = "VM.Standard.E4.Flex"
  kubernetes_version = "v1.33.1"

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
      subnet_id           = var.worker_nodes_private_subnet_id
    }
    size = each.value.number_of_nodes
  }

  node_shape_config {
    ocpus         = "1"
    memory_in_gbs = "8"
  }

  node_source_details {
    image_id                = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaayciyuq2akqdjmoxv444besgde5tbkcskcbj5dhewjnwhqqplnnq"
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = "50"
  }
  ssh_public_key = each.value.ssh_key
}
