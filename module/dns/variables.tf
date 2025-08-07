variable "tenancy_ocid" {
  type        = string
  description = "OCI Tenancy OCID"
  sensitive   = true
}

variable "user_ocid" {
  type        = string
  description = "User OCID for API Key Authentication"
  sensitive   = true
}

variable "fingerprint" {
  type        = string
  description = "API Key Fingerprint"
  sensitive   = true
}

variable "private_key_path" {
  type        = string
  description = "Local path to the OCI API private key"
  sensitive   = true
}


variable "lb_ocid" {
  description = "IPアドレスを取得したいロードバランサのOCID"
  type        = string
  default     = "" # 必須ではないためデフォルトは空
}

# variables.tf

variable "vcn_id" {
  description = "DNSリゾルバを関連付けるVCNのOCID"
  type        = string
}

# variables.tf

variable "endpoint_subnet_id" {
  description = "DNSエンドポイントを配置するプライベートサブネットのOCID"
  type        = string
}


# variables.tf
# variables.tf

variable "forwarding_rules" {
  description = "リゾルバに設定する転送ルールのマップ"
  type = map(object({
    client_address_conditions = optional(list(string))
    domains                   = list(string)
    destination_addresses     = list(string)
  }))
  default = {} # ルールが不要な場合でもエラーにならないようにデフォルト値を設定
}


variable "region" {
  description = "OCIリージョン"
  type        = string
  default     = "ap-tokyo-1"
}

variable "compartment_id" {
  description = "リソースを作成するコンパートメントのOCID"
  type        = string
  # この値はご自身の環境に合わせて設定してください
}

variable "private_zone_name" {
  description = "作成するプライベートDNSゾーンの名前"
  type        = string
  default     = "ec-gaihan-development.com"
}

variable "a_records" {
  description = "作成するAレコードのマップ（キー: サブドメイン, 値: IPアドレス）"
  type        = map(string)
  default     = {
    "graphql.dev.ec-gaihan-development.com" = "141.147.170.87"
  }
}
