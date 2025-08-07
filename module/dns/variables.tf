variable "env" {}

variable "compartment_ocid" {}

variable "vcn_id" {}

variable "subnet_id" {}

variable "load_balancer_ocid" {}

variable "forwarding_rules" {
  # description = "リゾルバに設定する転送ルールのマップ"
  # type = map(object({
  #   client_address_conditions = optional(list(string))
  #   domains                   = list(string)
  #   destination_addresses     = list(string)
  # }))
  # default = {} # ルールが不要な場合でもエラーにならないようにデフォルト値を設定
}
variable "private_zone_name" {
  # description = "作成するプライベートDNSゾーンの名前"
  # type        = string
  # default     = "ec-gaihan-development.com"
}

variable "a_records" {
  # description = "作成するAレコードのマップ（キー: サブドメイン, 値: IPアドレス）"
  # type        = map(string)
  # default = {
  #   "graphql.dev.ec-gaihan-development.com" = "141.147.170.87"
  # }
}
