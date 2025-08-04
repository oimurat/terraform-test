# --- OCI認証情報 ---
variable "tenancy_ocid" {
  description = "OCIテナンシーのOCID"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCIユーザーのOCID"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "APIキーのフィンガープリント"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "API秘密鍵ファイルへのパス"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "使用するOCIのリージョン"
  type        = string
}

# --- リソース設定 ---
variable "compartment_ocid" {
  description = "リソースを作成するコンパートメントのOCID"
  type        = string
}

# --- DNSデータ ---
variable "private_zone_name" {
  description = "作成するプライベートゾーンの名前"
  type        = string
  default     = "service.internal"
}

variable "a_records" {
  description = "作成するAレコードのマップ（キー: ホスト名, 値: IPアドレス）"
  type        = map(string)
  default = {
    "app01" = "10.0.20.45" #サーバーIPアドレス
  }
}