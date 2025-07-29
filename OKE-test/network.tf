# network.tf

# ==============================================================================
# Network Resources (VCN, Gateways, Route Tables, Security Lists, Subnets)
# ==============================================================================

# network.tf

# ==============================================================================
# Network Resources (VCN, Gateways, Route Tables, Security Lists, Subnets)
# ==============================================================================

# VCNの作成
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-vcn-tf"
  cidr_block     = var.vcn_cidr
}

# --- Gateways ---
resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-igw-tf"
}

resource "oci_core_nat_gateway" "oke_ngw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-ngw-tf"
}

# --- Service Gateway Data Source ---
# OCIの全てのサービスへのアクセスを可能にするサービスIDを動的に取得
data "oci_core_services" "all_oracle_services" {
  # プロバイダ設定に基づいて、現在のリージョンのサービスを取得します
  # 明示的にリージョンを指定する場合は、以下のようにコメントアウトを解除してください:
  # region = "ap-tokyo-1" # 例: 東京リージョン
}

# --- 現在のリージョン情報を取得するデータソース ---
# local変数で service_obj.name の比較に使用するため
# このデータソースは、現在のプロバイダ設定のリージョン情報を取得します。
data "oci_identity_regions" "current" {}


# --- Local value for Oracle Services Network CIDR and ID ---
# 公式ドキュメントの例を参考に、直接サービス名でアクセスを試みます。
# もし "All Services in Oracle Services Network" が見つからない場合、
# null エラーが再発する可能性があります。その場合は、terraform console で
# 正確な名前を特定し、ここに直接書き込む必要があります。
locals {
  # サービス名が map のキーとして存在するか確認し、存在すればそのオブジェクトを取得
  # try を使用して、サービスが存在しない場合に null を返すようにする
  oracle_services_network_object = try(
    data.oci_core_services.all_oracle_services.services["All Services in Oracle Services Network"],
    null
  )
  # 上記のオブジェクトから ID と CIDR_BLOCK を安全に取得
  oracle_services_network_id = try(local.oracle_services_network_object.id, null)
  oracle_services_network_cidr = try(local.oracle_services_network_object.cidr_block, null)
}


# --- Service Gateway Resource ---
# プライベートサブネットからOracleサービスへのアクセスを許可
resource "oci_core_service_gateway" "oke_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-sgw-tf"

  services {
    # local変数から ID を参照
    service_id = local.oracle_services_network_id
  }
}

# --- Route Tables ---
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-public-rt-tf"
  route_rules {
    destination     = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-private-rt-tf"
  route_rules {
    destination     = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.oke_ngw.id
  }
  route_rules {
    # local変数から CIDR ブロックを参照
    destination     = local.oracle_services_network_cidr
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}

# --- Security Lists ---
resource "oci_core_security_list" "node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-node-sl-tf"

  # OKEノードに必要なIngressルール (受信トラフィック)
  ingress_security_rules {
    protocol    = "6"  # TCP
    source      = var.vcn_cidr # VCN内からの全てのトラフィック
    tcp_options {
      # 構文修正: min/max を tcp_options の直下に
      min = 22
      max = 22
    }
    description = "Allow SSH from VCN (for management/troubleshooting)"
  }
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    tcp_options {
      min = 10250
      max = 10250
    }
    description = "Allow Kubelet from Control Plane (port 10250)"
  }
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.api_subnet_cidr # OKE APIサブネットから
    tcp_options {
      min = 10250
      max = 10250
    }
    description = "Allow Kubelet from Control Plane (port 10250) from API Subnet"
  }
  ingress_security_rules {
    protocol    = "6" # TCP (NodePort services)
    source      = "0.0.0.0/0"
    tcp_options {
      min = 30000
      max = 32767
    }
    description = "Allow NodePort services from anywhere"
  }
  ingress_security_rules {
    protocol    = "1" # ICMP (ping)
    source      = var.vcn_cidr
    icmp_options {
      type = 3 # Destination Unreachable
      code = 4 # Fragmentation Needed and Don't Fragment Bit Set
    }
    description = "Allow ICMP for path discovery (from VCN)"
  }
  ingress_security_rules {
    protocol = "all" # VCN内トラフィック (ノード間通信、CNIなど)
    source   = var.vcn_cidr
    description = "Allow all in-VCN traffic (node to node, CNI)"
  }

  # OKEノードに必要なEgressルール (送信トラフィック)
  egress_security_rules {
    protocol    = "6" # TCP
    destination = var.api_subnet_cidr # OKE APIエンドポイント
    tcp_options {
      min = 6443
      max = 6443
    }
    description = "Allow traffic to Kubernetes API (port 6443)"
  }
  egress_security_rules {
    protocol    = "6" # TCP (Docker registry, OS updates via NAT)
    destination = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
    description = "Allow HTTP to internet via NAT"
  }
  egress_security_rules {
    protocol    = "6" # TCP (Docker registry, OS updates via NAT)
    destination = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
    description = "Allow HTTPS to internet via NAT"
  }
  egress_security_rules {
    protocol    = "all" # Oracle Services Network (Service Gateway経由)
    # local変数から CIDR ブロックを参照
    destination = local.oracle_services_network_cidr
    description = "Allow all traffic to Oracle Services Network via Service Gateway"
  }
  egress_security_rules {
    protocol    = "6" # TCP (DNS)
    destination = "all-vcn-internal-dns-servers"
    tcp_options {
      min = 53
      max = 53
    }
    description = "Allow DNS (TCP) queries"
  }
  egress_security_rules {
    protocol    = "17" # UDP (DNS)
    destination = "all-vcn-internal-dns-servers"
    udp_options {
      min = 53
      max = 53
    }
    description = "Allow DNS (UDP) queries"
  }
  egress_security_rules {
    protocol    = "all" # VCN内への全てのトラフィック
    destination = var.vcn_cidr
    description = "Allow all in-VCN traffic"
  }
}

# --- Subnets ---
resource "oci_core_subnet" "oke_api_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.api_subnet_cidr
  display_name               = "oke-api-subnet-tf"
  route_table_id             = oci_core_route_table.public_rt.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "oke_lb_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.lb_subnet_cidr
  display_name               = "oke-lb-subnet-tf"
  route_table_id             = oci_core_route_table.public_rt.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "oke_node_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.node_subnet_cidr
  display_name               = "oke-node-subnet-tf"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private_rt.id
  security_list_ids          = [oci_core_security_list.node_sl.id]
}

/*# VCNの作成
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-vcn-tf"
  cidr_block     = var.vcn_cidr
}

# --- Gateways ---
resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-igw-tf"
}

resource "oci_core_nat_gateway" "oke_ngw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-ngw-tf"
}

# --- Service Gateway Data Source ---
# OCIの全てのサービスへのアクセスを可能にするサービスIDを動的に取得
data "oci_core_services" "all_oracle_services" {
  # プロバイダ設定に基づいて、現在のリージョンのサービスを取得します
  # 明示的にリージョンを指定する場合は、以下のようにコメントアウトを解除してください:
  # region = "ap-tokyo-1" # 例: 東京リージョン
}

# --- 現在のリージョン情報を取得するデータソース ---
# local変数で service_obj.name の比較に使用するため
data "oci_identity_regions" "current" {
  # compartment_id は不要なので削除しました
  # このデータソースは、現在のプロバイダ設定のリージョン情報を取得します。
}

# --- Local value to safely get the 'All Services in Oracle Services Network' service ---

# network.tf 内の locals ブロックを修正

# network.tf 内の locals ブロックを一時的に修正 (デバッグ出力取得のため)

# network.tf 内の locals ブロックを修正

locals {
  # OCIの「すべてのサービス」の正確な名前はリージョンによって異なる場合があるため、
  # 優先順位を付けてパターンを試す。
  # data.oci_identity_regions.current.regions[0].key は "ap-tokyo-1" のようなキーを返す。

  # サービス名が解決できない場合に備え、安全にサービスIDとCIDRブロックを取得する。
  # coalesce を使用して、存在しない場合は空文字列を返すことで null 参照エラーを防ぐ。

  # まず、data.oci_core_services.all_oracle_services.services が実際にマップを持っていることを前提とします。
  # サービス名として使われる可能性のある候補リスト
  oracle_service_names = [
    "All Services in Oracle Services Network",
    "All ${data.oci_identity_regions.current.regions[0].key} Services in Oracle Services Network",
    "All ${data.oci_identity_regions.current.regions[0].name} Services in Oracle Services Network",
    "AllOCI Services" # 古い環境や特定のテナンシーで使われる可能性
  ]

  # これらのサービス名から、実際に存在する最初のサービスオブジェクトを取得
  # try と for を組み合わせて、確実に存在するサービスオブジェクトを取得する
  found_oracle_service_object = try(
    one([
      for service_name in local.oracle_service_names :
      data.oci_core_services.all_oracle_services.services[service_name]
      if contains(keys(data.oci_core_services.all_oracle_services.services), service_name)
    ]),
    null # どのサービス名も見つからなかった場合は null を返す
  )

  # 最終的なサービスIDとCIDRブロック。found_oracle_service_object が null の場合はエラーにならないよう処理
  oracle_services_network_service_id        = try(local.found_oracle_service_object.id, null)
  oracle_services_network_service_cidr_block = try(local.found_oracle_service_object.cidr_block, null)
}

# --- Service Gateway Resource ---
# プライベートサブネットからOracleサービスへのアクセスを許可
# network.tf 内の Service Gateway Resource を修正
resource "oci_core_service_gateway" "oke_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-sgw-tf"

  services {
    # 修正: 新しい local 変数で ID を参照
    service_id = local.oracle_services_network_service_id
  }
}

# network.tf 内の private_rt ルートテーブルを修正
resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-private-rt-tf"
  route_rules {
    destination     = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.oke_ngw.id
  }
  route_rules {
    # 修正: 新しい local 変数で CIDR ブロックを参照
    destination     = local.oracle_services_network_service_cidr_block
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}



# --- Route Tables ---
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-public-rt-tf"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-private-rt-tf"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.oke_ngw.id
  }
  route_rules {
    destination       = local.oracle_services_network_service.cidr_block
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}

# --- Security Lists ---
resource "oci_core_security_list" "node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "oke-node-sl-tf"

  # OKEノードに必要なIngressルール (受信トラフィック)
  ingress_security_rules {
    protocol = "6"          # TCP
    source   = var.vcn_cidr # VCN内からの全てのトラフィック
    tcp_options {
      min = 22 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 22 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow SSH from VCN (for management/troubleshooting)"
  }
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.vcn_cidr
    tcp_options {
      min = 10250 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 10250 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow Kubelet from Control Plane (port 10250)"
  }
  ingress_security_rules {
    protocol = "6"                 # TCP
    source   = var.api_subnet_cidr # OKE APIサブネットから
    tcp_options {
      min = 10250 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 10250 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow Kubelet from Control Plane (port 10250) from API Subnet"
  }
  ingress_security_rules {
    protocol = "6" # TCP (NodePort services)
    source   = "0.0.0.0/0"
    tcp_options {
      min = 30000 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 32767 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow NodePort services from anywhere"
  }
  ingress_security_rules {
    protocol = "1" # ICMP (ping)
    source   = var.vcn_cidr
    icmp_options {
      type = 3 # Destination Unreachable
      code = 4 # Fragmentation Needed and Don't Fragment Bit Set
    }
    description = "Allow ICMP for path discovery (from VCN)"
  }
  ingress_security_rules {
    protocol    = "all" # VCN内トラフィック (ノード間通信、CNIなど)
    source      = var.vcn_cidr
    description = "Allow all in-VCN traffic (node to node, CNI)"
  }

  # OKEノードに必要なEgressルール (送信トラフィック)
  egress_security_rules {
    protocol    = "6"                 # TCP
    destination = var.api_subnet_cidr # OKE APIエンドポイント
    tcp_options {
      min = 6443 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 6443 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow traffic to Kubernetes API (port 6443)"
  }
  egress_security_rules {
    protocol    = "6" # TCP (Docker registry, OS updates via NAT)
    destination = "0.0.0.0/0"
    tcp_options {
      min = 80 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 80 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow HTTP to internet via NAT"
  }
  egress_security_rules {
    protocol    = "6" # TCP (Docker registry, OS updates via NAT)
    destination = "0.0.0.0/0"
    tcp_options {
      min = 443 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 443 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow HTTPS to internet via NAT"
  }
  egress_security_rules {
    protocol    = "all" # Oracle Services Network (Service Gateway経由)
    destination = local.oracle_services_network_service.cidr_block
    description = "Allow all traffic to Oracle Services Network via Service Gateway"
  }
  egress_security_rules {
    protocol    = "6" # TCP (DNS)
    destination = "all-vcn-internal-dns-servers"
    tcp_options {
      min = 53 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 53 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow DNS (TCP) queries"
  }
  egress_security_rules {
    protocol    = "17" # UDP (DNS)
    destination = "all-vcn-internal-dns-servers"
    udp_options {
      min = 53 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
      max = 53 # <<-- 参考コードに合わせて destination_port_range ブロックを削除
    }
    description = "Allow DNS (UDP) queries"
  }
  # network.tf 内の Security List (node_sl) の Egress Rule を修正
# (該当する egress_security_rules のみ抜粋)
  egress_security_rules {
    protocol    = "all" # Oracle Services Network (Service Gateway経由)
    # 修正: 新しい local 変数で CIDR ブロックを参照
    destination = local.oracle_services_network_service_cidr_block
    description = "Allow all traffic to Oracle Services Network via Service Gateway"
  }
}

# --- Subnets ---
resource "oci_core_subnet" "oke_api_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.api_subnet_cidr
  display_name               = "oke-api-subnet-tf"
  route_table_id             = oci_core_route_table.public_rt.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "oke_lb_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.lb_subnet_cidr
  display_name               = "oke-lb-subnet-tf"
  route_table_id             = oci_core_route_table.public_rt.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "oke_node_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.node_subnet_cidr
  display_name               = "oke-node-subnet-tf"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private_rt.id
  security_list_ids          = [oci_core_security_list.node_sl.id]
}

# network.tf の末尾に一時的に追加 (デバッグ用)

output "debug_all_oracle_services_data" {
  value       = data.oci_core_services.all_oracle_services.services
  description = "DEBUG: Raw output of all_oracle_services data source."
}

output "debug_current_regions_data" {
  value       = data.oci_identity_regions.current.regions
  description = "DEBUG: Raw output of current_regions data source."
}

output "debug_filtered_service_count" {
  value       = length([
    for k, service_obj in data.oci_core_services.all_oracle_services.services : service_obj
    if service_obj.name == "All Services in Oracle Services Network" ||
       service_obj.name == "All ${data.oci_identity_regions.current.regions[0].key} Services in Oracle Services Network" ||
       service_obj.name == "All ${data.oci_identity_regions.current.regions[0].name} Services in Oracle Services Network" ||
       service_obj.name == "AllOCI Services"
  ])
  description = "DEBUG: Count of services matching the filter criteria."
}
*/