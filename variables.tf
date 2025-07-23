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
  description = "リソースを作成するコンパートメントのOCID"
  type        = string
}

variable "instance_image_ocid" {
  description = "インスタンスに使用するイメージのOCID"
  type        = string
}

variable "subnet_ocid" {
  description = "インスタンスを配置するサブネットのOCID"
  type        = string
}