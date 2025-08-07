# --- 環境変数 ---

variable "env" {
  description = "開発環境名"
  type        = string
}

# --- OCIプロバイダ認証用の変数 ---

variable "tenancy_ocid" {
  description = "OCIテナンシーのOCID"
  type        = string
}

variable "user_ocid" {
  description = "OCIユーザーのOCID"
  type        = string
}

variable "fingerprint" {
  description = "APIキーのフィンガープリント"
  type        = string
}

variable "private_key" {
  description = "API秘密鍵の中身"
  type        = string
}

variable "region" {
  description = "利用するOCIリージョン"
  type        = string
}

# --- リソース作成用の変数 ---

variable "compartment_ocid" {
  description = "開発環境コンパートメントのOCID"
  type        = string
}

variable "load_balancer_ocid" {
  description = "開発環境ロードバランサーのOCID"
  type        = string
}

variable "subnet_ocid" {
  description = "開発環境サブネットのOCID"
  type        = string
}

variable "vcn_cidr_block" {
  description = "開発環境VCNのCIDRブロック"
  default     = "10.3.0.0/16"
}

variable "k8s_api_endpoint_private_subnet_cidr_block" {
  description = "開発環境k8s APIエンドポイントプライベートサブネットのCIDRブロック"
  default     = "10.3.0.0/28"
}

variable "worker_nodes_private_subnet_cidr_block" {
  description = "開発環境ワーカーノードプライベートサブネットのCIDRブロック"
  default     = "10.3.10.0/24"
}

variable "service_loadbalancers_public_subnet_cidr_block" {
  description = "開発環境サービスロードバランサーパブリックサブネットのCIDRブロック"
  default     = "10.3.20.0/24"
}

variable "node_pools" {
  description = "開発環境ノードプールの設定"
  type        = map(any)
}
