# main.tf

# ==============================================================================
# OKE-Specific Resources (IAM Policy, Cluster, Nodepool)
# ==============================================================================

# OKEサービスがリソースを管理するためのIAMポリシー (必須)
# OKEの公式ドキュメントに基づいて、より具体的な権限を追加
resource "oci_identity_policy" "oke_service_policy" {
  name           = "oke-service-policy-tf"
  description    = "Policy for OKE service to manage necessary resources in the compartment where OKE cluster is deployed."
  compartment_id = var.compartment_ocid # クラスターがデプロイされるコンパートメントに設定

  statements = [
    "Allow service OKE to manage vcns in compartment id ${var.compartment_ocid}",
    "Allow service OKE to manage instance-family in compartment id ${var.compartment_ocid}",
    "Allow service OKE to manage volume-family in compartment id ${var.compartment_ocid}",
    "Allow service OKE to manage load-balancer-family in compartment id ${var.compartment_ocid}",
    "Allow service OKE to use object-family in compartment id ${var.compartment_ocid}", # For Container Registry pull, etc.
    "Allow service OKE to use metrics in compartment id ${var.compartment_ocid}",
    "Allow service OKE to use ons-topics in compartment id ${var.compartment_ocid}",
    "Allow service OKE to use functions-family in compartment id ${var.compartment_ocid}",
  ]
}

# AD情報を取得 (テナンシー全体で共通)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# OKEクラスタ
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "oke-cluster-tf"
  # network.tf で定義されているVCNを直接参照
  vcn_id = oci_core_vcn.oke_vcn.id

  endpoint_config {
    # network.tf で定義されているAPIサブネットを直接参照
    subnet_id = oci_core_subnet.oke_api_subnet.id
  }
  options {
    # network.tf で定義されているLBサブネットを直接参照
    service_lb_subnet_ids = [oci_core_subnet.oke_lb_subnet.id]
  }
  depends_on = [oci_identity_policy.oke_service_policy]
}

# ノードプール
resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "nodepool-tf"
  node_shape         = var.node_shape
  node_shape_config {
    memory_in_gbs = var.node_memory_in_gbs
    ocpus         = var.node_ocpus
  }
  node_source_details {
    # 指定されたOCIノードイメージのOCIDを直接使用
    image_id    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaayciyuq2akqdjmoxv444besgde5tbkcskcbj5dhewjnwhqqplnnq"
    source_type = "image"
  }
  node_config_details {
    size = var.node_count
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      # network.tf で定義されているノードサブネットを直接参照
      subnet_id = oci_core_subnet.oke_node_subnet.id
    }
  }
  depends_on = [oci_containerengine_cluster.oke_cluster]
}

# ==============================================================================
# Outputs
# ==============================================================================
output "cluster_id" {
  value       = oci_containerengine_cluster.oke_cluster.id
  description = "The OCID of the OKE cluster."
}

output "cluster_name" {
  value       = oci_containerengine_cluster.oke_cluster.name
  description = "The name of the OKE cluster."
}

output "nodepool_id" {
  value       = oci_containerengine_node_pool.oke_node_pool.id
  description = "The OCID of the OKE node pool."
}

output "nodepool_name" {
  value       = oci_containerengine_node_pool.oke_node_pool.name
  description = "The name of the OKE node pool."
}