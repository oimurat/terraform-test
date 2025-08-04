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