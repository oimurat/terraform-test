# VCNを作成
resource "oci_core_vcn" "ec_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.env}-VCN"
}

# Internet Gatewayを作成
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.env}-Internet-Gateway"
  vcn_id         = oci_core_vcn.ec_vcn.id
}

# NAT Gatewayを作成
resource "oci_core_nat_gateway" "ngw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.env}-NAT-Gateway"
  vcn_id         = oci_core_vcn.ec_vcn.id
}

# Service Gatewayを作成
resource "oci_core_service_gateway" "sgw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.env}-Service-Gateway"
  vcn_id         = oci_core_vcn.ec_vcn.id
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

# すべてのOCIサービスを取得
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# k8s API Endpoint用のプライベートサブネットを作成
resource "oci_core_subnet" "Private-Subnet-For-k8s-API-Endpoint" {
  cidr_block                 = var.k8s_api_endpoint_private_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "${var.env}-Private-Subnet-For-k8s-API-Endpoint"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-k8s-API-Endpoint-Subnet.id
  security_list_ids          = [oci_core_security_list.Security-List-For-k8s-APIendpoint.id]
  vcn_id                     = oci_core_vcn.ec_vcn.id
}

# k8s API Endpoint用のプライベートサブネットのRoute Tableを作成
resource "oci_core_route_table" "Route-Table-For-Private-k8s-API-Endpoint-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.ec_vcn.id
  display_name   = "${var.env}-RT-For-k8s-API-Endpoint"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw.id
  }
  route_rules {
    destination       = "all-nrt-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

# k8s API Endpoint用のプライベートサブネットのセキュリティリストを作成
resource "oci_core_subnet" "Private-Subnet-For-k8s-API-Endpoint" {
  cidr_block                 = var.k8s_api_endpoint_private_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "-Private-Subnet-For-k8ss-API-Endpoint" #${var.env}
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-k8s-API-Endpoint-Subnet.id
  security_list_ids          = [oci_core_security_list.Security-List-For-k8s-APIendpoint.id]
  vcn_id                     = oci_core_vcn.this.id
}

resource "oci_core_route_table" "Route-Table-For-Private-k8s-API-Endpoint-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "-RT-For-k8ss-API-Endpoint" #${var.env}
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw.id
  }
  route_rules {
    destination       = "all-nrt-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

resource "oci_core_security_list" "Security-List-For-k8s-APIendpoint" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "-SL-For-k8ss-API-Endpoint" #${var.env}

  ingress_security_rules {
    protocol  = "6"
    source    = var.worker_nodes_private_subnet_cidr_block
    stateless = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  ingress_security_rules {
    protocol  = "6"
    source    = var.worker_nodes_private_subnet_cidr_block
    stateless = false
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    destination = var.worker_nodes_private_subnet_cidr_block
    protocol    = "6"
    stateless   = false
  }
  egress_security_rules {
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      min = 443
      max = 443
    }
  }
}


# Worker Nodes用のプライベートサブネットを作成
resource "oci_core_subnet" "Private-Subnet-For-Worker-Nodes" {
  cidr_block                 = var.worker_nodes_private_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "${var.env}-Private-Subnet-For-Worker-Nodes"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-Subnet-For-Worker-Nodes.id
  security_list_ids          = [oci_core_security_list.Security-List-For-Private-Subnet-For-Worker-Nodes.id]
  vcn_id                     = oci_core_vcn.ec_vcn.id
}

# Worker Nodes用のプライベートサブネットのRoute Tableを作成
resource "oci_core_route_table" "Route-Table-For-Private-Subnet-For-Worker-Nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.ec_vcn.id
  display_name   = "${var.env}-RT-For-Worker-Nodes"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw.id
  }
}

# Worker Nodes用のプライベートサブネットのセキュリティリストを作成
resource "oci_core_security_list" "Security-List-For-Private-Subnet-For-Worker-Nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "-SL-For-Worker-Nodes" #${var.env}

  # イングレス・ルール
  ingress_security_rules {
    protocol    = "6"
    source      = var.worker_nodes_private_subnet_cidr_block
    stateless   = false
    description = "あるワーカー・ノードのポッドが他のワーカー・ノードのポッドと通信することを許可します。"
  }
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.k8s_api_endpoint_private_subnet_cidr_block
    stateless   = false
    description = "Kubernetesコントロール・プレーンがワーカー・ノードと通信することを許可します。"
  }
  ingress_security_rules {
    protocol  = "1" # ICMP
    source    = "0.0.0.0/0"
    stateless = false
    icmp_options {
      type = 3
      code = 4
    }
    description = "パス検出。"
  }


  ingress_security_rules {
    protocol  = "6"
    source    = var.service_loadbalancers_public_subnet_cidr_block
    stateless = false
    tcp_options {
      min = 30000
      max = 32767
    }
    description = "ロード・バランサからワーカー・ノード・ポートへの通信。"
  }
  ingress_security_rules {
    protocol  = "6"
    source    = var.service_loadbalancers_public_subnet_cidr_block
    stateless = false
    tcp_options {
      min = 10256
      max = 10256
    }
    description = "ロード・バランサがワーカー・ノードでkube-proxyと通信できるようにします。"
  }

  # エグレス・ルール
  egress_security_rules {
    protocol    = "6"
    destination = var.worker_nodes_private_subnet_cidr_block
    stateless   = false
    description = "あるワーカー・ノードのポッドが他のワーカー・ノードのポッドと通信することを許可します。"
  }
  egress_security_rules {
    protocol    = "1" # ICMP
    destination = "0.0.0.0/0"
    stateless   = false
    icmp_options {
      type = 3
      code = 4
    }
    description = "パス検出。"
  }
  egress_security_rules {
    protocol         = "6" # TCP
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    stateless        = false
    description      = "ワーカー・ノードがOKEと通信することを許可します。"
  }
  egress_security_rules {
    protocol    = "6" # TCP
    destination = var.k8s_api_endpoint_private_subnet_cidr_block
    stateless   = false
    tcp_options {
      min = 6443
      max = 6443
    }
    description = "KubernetesワーカーからKubernetes APIエンドポイントへの通信。"
  }
  egress_security_rules {
    protocol    = "6" # TCP
    destination = var.k8s_api_endpoint_private_subnet_cidr_block
    stateless   = false
    tcp_options {
      min = 12250
      max = 12250
    }
    description = "Kubernetesワーカーからコントロール・プレーンへの通信。"
  }
  egress_security_rules {
    protocol    = "6" # TCP
    destination = "0.0.0.0/0"
    stateless   = false
    description = "ワーカー・ノードがインターネットと通信することを許可します (オプション)。"
  }
}


# Load Balancers用のパブリックサブネットを作成
resource "oci_core_subnet" "Public-Subnet-For-Load-Balancers" {
  cidr_block                 = var.service_loadbalancers_public_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "${var.env}-Public-Subnet-For-Load-Balancers"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.Route-Table-For-Public-Load-Balancers-Subnet.id
  security_list_ids          = [oci_core_security_list.Security-List-For-Public-Load-Balancers-Subnet.id]
  vcn_id                     = oci_core_vcn.ec_vcn.id
}

# Load Balancers用のパブリックサブネットのRoute Tableを作成
resource "oci_core_route_table" "Route-Table-For-Public-Load-Balancers-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.ec_vcn.id
  display_name   = "${var.env}-RT-For-Load-Balancers"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Load Balancers用のパブリックサブネットのセキュリティリストを作成

resource "oci_core_security_list" "Security-List-For-Public-Load-Balancers-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "-SL-For-Load-Balancers" #${var.env}

  # イングレス・ルール
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    description = "アプリケーション固有 (インターネットまたは特定のCIDR)"
  }

  # エグレス・ルール
  egress_security_rules {
    destination = var.worker_nodes_private_subnet_cidr_block
    protocol    = "6"
    stateless   = false
    tcp_options {
      min = 30000
      max = 32767
    }
    description = "ロード・バランサからワーカー・ノード・ポートへの通信。"
  }
  egress_security_rules {
    destination = var.worker_nodes_private_subnet_cidr_block
    protocol    = "6"
    stateless   = false
    tcp_options {
      min = 10256
      max = 10256
    }
    description = "ロード・バランサがワーカー・ノードでkube-proxyと通信できるようにします。"
  }
}

