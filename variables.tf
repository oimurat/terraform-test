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

variable "testing_compartment_ocid" {
  description = "リソースを作成するtestingコンパートメントのOCID"
  type        = string
}

variable "subnet_ocid" {
  description = "サブネットのOCID"
  type        = string
}

variable "load_balancer_ocid" {
  description = "WAFを配置するロードバランサーのOCID"
  type        = string
}

variable "management_compartment_ocid" {
  description = "管理用コンパートメントのOCID"
  type        = string
}

variable "ec_service_compartment_ocid" {
  description = "外販用コンパートメントのOCID"
  type        = string
}