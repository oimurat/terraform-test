# VCN
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${var.oke_cluster_name}-vcn"
  dns_label      = "${replace(var.oke_cluster_name, "-", "")}vcn"
  is_ipv6enabled = false
}

# Internet Gateway
resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-igw"
  enabled        = true
}

# NAT Gateway
resource "oci_core_nat_gateway" "oke_nat_gw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-nat-gw"
}

# Service Gateway
resource "oci_core_service_gateway" "oke_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-sgw"

  services {
    # 以前: service_id = "ocid1.service.oc1.phx.oracle_object_storage" # リージョンに合わせて変更が必要な場合あり
    # 修正後 (東京リージョン向け):
    service_id = "ocid1.service.oc1.ap-tokyo-1.objectstorage" # 東京リージョンのObject StorageサービスID
  }
}

# Route Table for Private Subnet (Nodes) - routes to NAT Gateway and Service Gateway
resource "oci_core_route_table" "oke_private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_nat_gw.id
  }
  route_rules {
    # 以前: destination = "all-phx-services-in-oracle-services-network"
    # 修正後 (東京リージョン向け):
    destination       = "all-ap-tokyo-1-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}

# Security List for K8s API Subnet
resource "oci_core_security_list" "oke_api_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-api-sl"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  ingress_security_rules {
    protocol = "6" # TCP for ssh to bastion if needed (adjust source if you have bastion)
    source   = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
    stateless = false
  }
}

# Security List for Node Subnet
resource "oci_core_security_list" "oke_node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-node-sl"

  ingress_security_rules {
    protocol = "6" # TCP for SSH
    source   = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    protocol = "6" # TCP for Kubelet
    source   = var.k8s_api_subnet_cidr
    stateless = false
    tcp_options {
      min = 10250
      max = 10250
    }
  }
  ingress_security_rules {
    protocol = "6" # TCP for NodePort services
    source   = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 30000
      max = 32767
    }
  }
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
    stateless = false
  }
}

# Security List for LB Subnet
resource "oci_core_security_list" "oke_lb_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-lb-sl"

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0" # Allow all incoming traffic to the LB (adjust if needed)
    stateless = false
  }
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
    stateless = false
  }
}

# K8s API Subnet
resource "oci_core_subnet" "oke_api_subnet" {
  compartment_id   = var.compartment_ocid
  vcn_id           = oci_core_vcn.oke_vcn.id
  cidr_block       = var.k8s_api_subnet_cidr
  display_name     = "${var.oke_cluster_name}-api-subnet"
  security_list_ids = [oci_core_security_list.oke_api_sl.id]
  route_table_id   = oci_core_vcn.oke_vcn.default_route_table_id # 通常はデフォルトルートテーブル
  prohibit_public_ip_on_vnic = false # APIエンドポイントは公開IPが必要
}

# Node Subnet
resource "oci_core_subnet" "oke_node_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.node_subnet_cidr
  display_name               = "${var.oke_cluster_name}-node-subnet"
  security_list_ids          = [oci_core_security_list.oke_node_sl.id]
  route_table_id             = oci_core_vcn.oke_vcn.default_route_table_id # ノードからはインターネットへアクセスできるようにIGWやNAT GWへのルートが必要
  prohibit_public_ip_on_vnic = true # ノードはプライベートIPのみ
}

# Load Balancer Subnet
resource "oci_core_subnet" "oke_lb_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.lb_subnet_cidr
  display_name               = "${var.oke_cluster_name}-lb-subnet"
  security_list_ids          = [oci_core_security_list.oke_lb_sl.id]
  route_table_id             = oci_core_vcn.oke_vcn.default_route_table_id
  prohibit_public_ip_on_vnic = false # LBは公開IPが必要
}

# Route Table for Public Subnets (API, LB) - routes to Internet Gateway
resource "oci_core_route_table" "oke_public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

# Route Table for Private Subnet (Nodes) - routes to NAT Gateway and Service Gateway
/*resource "oci_core_route_table" "oke_private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.oke_cluster_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_nat_gw.id
  }
  route_rules {
    destination       = "all-phx-services-in-oracle-services-network" # リージョンに合わせて変更が必要な場合あり
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}
*/

# Associate route tables with subnets
resource "oci_core_subnet" "oke_api_subnet_with_rt" {
  for_each = { "api" : oci_core_subnet.oke_api_subnet, "lb" : oci_core_subnet.oke_lb_subnet }
  compartment_id = each.value.compartment_id
  vcn_id = each.value.vcn_id
  cidr_block = each.value.cidr_block
  display_name = each.value.display_name
  security_list_ids = each.value.security_list_ids
  route_table_id = oci_core_route_table.oke_public_rt.id
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  depends_on = [oci_core_route_table.oke_public_rt]
}

resource "oci_core_subnet" "oke_node_subnet_with_rt" {
  compartment_id = oci_core_subnet.oke_node_subnet.compartment_id
  vcn_id = oci_core_subnet.oke_node_subnet.vcn_id
  cidr_block = oci_core_subnet.oke_node_subnet.cidr_block
  display_name = oci_core_subnet.oke_node_subnet.display_name
  security_list_ids = oci_core_subnet.oke_node_subnet.security_list_ids
  route_table_id = oci_core_route_table.oke_private_rt.id
  prohibit_public_ip_on_vnic = oci_core_subnet.oke_node_subnet.prohibit_public_ip_on_vnic
  depends_on = [oci_core_route_table.oke_private_rt]
}


# OKE Cluster
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id          = var.compartment_ocid
  name                    = var.oke_cluster_name
  kubernetes_version      = var.oke_kubernetes_version
  vcn_id                  = oci_core_vcn.oke_vcn.id
  endpoint_config {
    subnet_id = oci_core_subnet.oke_api_subnet.id
    is_public_ip_enabled = true # APIエンドポイントは公開IP
  }
  options {
    #kubernetes_dashboard_enabled = false
    #tiller_enabled               = false
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    admission_controller_options {
      is_pod_security_policy_enabled = false
    }
    service_lb_subnet_ids = [oci_core_subnet.oke_lb_subnet.id]
  }
}

# OKE Node Pool
resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id        = oci_containerengine_cluster.oke_cluster.id
  compartment_id    = var.compartment_ocid
  name              = "${var.oke_cluster_name}-node-pool"
  kubernetes_version = var.oke_kubernetes_version # クラスターバージョンと合わせる
  node_shape        = var.node_shape
  node_shape_config {
    ocpus = var.node_ocpus
    memory_in_gbs = var.node_memory_in_gbs
  }
  node_source_details {
    image_id    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaayciyuq2akqdjmoxv444besgde5tbkcskcbj5dhewjnwhqqplnnq" # ご指定のイメージOCID
    source_type = "IMAGE"
  }
  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.oke_node_subnet.id
    }
    size = var.node_count
    is_pv_encryption_in_transit_enabled = true # 推奨
  }
  # SSHキーペアは別途作成し、fingerprintをここに指定するか、ユーザーデータで設定する
  # ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..." # ここに公開鍵の内容を直接記述するか、ファイルから読み込む
}

# Data Source to get Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Data Source to get Oracle Linux 9 Image OCID
data "oci_core_images" "oracle_linux_image" {
  compartment_id = var.compartment_ocid
  operating_system = "Oracle Linux"
  operating_system_version = "9"
  shape = var.node_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

output "oke_cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.id
}

output "oke_cluster_endpoint" {
  value = oci_containerengine_cluster.oke_cluster.endpoints[0].kubernetes
  description = "The Kubernetes API endpoint of the OKE cluster."
}

output "oke_node_pool_id" {
  value = oci_containerengine_node_pool.oke_node_pool.id
}

output "kubeconfig_file" {
  value = "To generate kubeconfig, use 'oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke_cluster.id} --file C://Users//odaj//Desktop//terraform-test-20250729.kube/config --region ${var.region} --token-version 2.0 --kube-endpoint PUBLIC_ENDPOINT'"
}