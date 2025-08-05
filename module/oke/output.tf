output "oke_cluster_OCID" {
  value = oci_containerengine_cluster.oke_cluster.id
}

output "oke_cluster_name" {
  value = oci_containerengine_cluster.oke_cluster.name
}

output "oke_cluster_state" {
  value = oci_containerengine_cluster.oke_cluster.state
}

output "oke_cluster_time_created" {
  value = oci_containerengine_cluster.oke_cluster.metadata.time_created
}

output "node_pool_OCID" {
  value = oci_containerengine_node_pool.node_pool_one.id
}

output "node_pool_name" {
  value = oci_containerengine_node_pool.node_pool_one.name
}

output "node_pool_state" {
  value = oci_containerengine_node_pool.node_pool_one.state
}

output "node_pool_time_created" {
  value = oci_containerengine_node_pool.node_pool_one.time_created
}

