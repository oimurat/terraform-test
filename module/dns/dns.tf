# ---パブリックゾーン作成時---

# コンパートメント内の【すべて】のロードバランサ情報をリストとして取得
data "oci_load_balancers" "all_compartment_lbs" {
  compartment_id = var.compartment_ocid
}

# 取得したリストから、指定したOCIDに一致するLBを一つだけ探し出す
locals {
  # データソースからLBのOCIDのリストを取得
  lb_list = var.load_balancer_ocid != "" ? data.oci_load_balancers.all_compartment_lbs.load_balancers : []

  # リストの中から var.load_balancer_ocid とOCIDが一致するものを抽出
  target_lb_object = [for lb in local.lb_list : lb if lb.id == var.load_balancer_ocid]
}

# パブリックゾーンを作成
resource "oci_dns_zone" "public_zone" {
  compartment_id = var.compartment_ocid
  name           = var.public_zone_name
  zone_type      = "PRIMARY"
}

# Aレコードを作成
resource "oci_dns_rrset" "public_a_records" {
  for_each = var.a_records

  zone_name_or_id = oci_dns_zone.public_zone.id
  domain          = each.key
  rtype           = "A"

  items {
    domain = each.key
    rdata  = each.value
    rtype  = "A"
    ttl    = 300
  }
}

# ロードバランサ用のAレコードを作成
resource "oci_dns_rrset" "lb_a_records" {
  # ロードバランサが1つの場合はAレコードを作成
  count = length(local.target_lb_object) == 1 ? 1 : 0

  zone_name_or_id = oci_dns_zone.public_zone.id
  domain          = "graphql.dev.${oci_dns_zone.public_zone.name}"
  rtype           = "A"

  items {
    domain = "graphql.dev.${oci_dns_zone.public_zone.name}"
    rdata  = local.target_lb_object[0].ip_addresses[0]
    rtype  = "A"
    ttl    = 300
  }
}


# ---プライベートゾーン作成時---

# # プライベートDNSビューの情報を取得
# data "oci_dns_views" "private_view" {
#   compartment_id = var.compartment_ocid
#   scope          = "PRIVATE"
# }

# # VCNにデフォルトで存在するDNSリゾルバの情報を取得
# data "oci_core_vcn_dns_resolver_association" "vcn_dns_resolver_association" {
#   vcn_id = var.vcn_id
# }

# # コンパートメント内の【すべて】のロードバランサ情報をリストとして取得
# data "oci_load_balancers" "all_compartment_lbs" {
#   compartment_id = var.compartment_ocid
# }

# # 取得したリストから、指定したOCIDに一致するLBを一つだけ探し出す
# locals {
#   # var.lb_ocidが空の場合は空のリスト、それ以外はデータソースからリストを取得
#   lb_list = var.load_balancer_ocid != "" ? data.oci_load_balancers.all_compartment_lbs.load_balancers : []

#   # forループを使い、リストの中から var.lb_ocid とIDが一致するものを抽出
#   target_lb_object = [for lb in local.lb_list : lb if lb.id == var.load_balancer_ocid]
# }

# # プライベートDNSゾーンを作成
# resource "oci_dns_zone" "private_zone" {
#   compartment_id = var.compartment_ocid
#   name           = var.private_zone_name
#   zone_type      = "PRIMARY"
#   scope          = "PRIVATE"
#   view_id        = data.oci_dns_views.private_view.views[0].id
# }

# # エンドポイント、リゾルバ・ルールの定義
# resource "oci_dns_resolver_endpoint" "forwarding_endpoint" {
#   name          = "forwarding_ep"
#   resolver_id   = data.oci_core_vcn_dns_resolver_association.vcn_dns_resolver_association.dns_resolver_id
#   subnet_id     = var.subnet_id
#   is_forwarding = true
#   is_listening  = false
#   scope         = "PRIVATE"
# }

# resource "oci_dns_resolver_endpoint" "listening_endpoint" {
#   name          = "listening_ep"
#   resolver_id   = data.oci_core_vcn_dns_resolver_association.vcn_dns_resolver_association.dns_resolver_id
#   subnet_id     = var.subnet_id
#   is_forwarding = false
#   is_listening  = true
#   scope         = "PRIVATE"
# }

# resource "oci_dns_resolver" "resolver_rules" {
#   resolver_id = data.oci_core_vcn_dns_resolver_association.vcn_dns_resolver_association.dns_resolver_id
#   scope       = "PRIVATE"
#   dynamic "rules" {
#     for_each = var.forwarding_rules
#     content {
#       action                    = "FORWARD"
#       client_address_conditions = rules.value.client_address_conditions
#       qname_cover_conditions    = rules.value.domains
#       destination_addresses     = rules.value.destination_addresses
#       source_endpoint_name      = oci_dns_resolver_endpoint.forwarding_endpoint.name
#     }
#   }
#   lifecycle {
#     ignore_changes = [rules]
#   }
# }

# # 通常のAレコードを作成
# resource "oci_dns_rrset" "private_a_records" {
#   for_each = var.a_records

#   zone_name_or_id = oci_dns_zone.private_zone.id
#   domain          = each.key
#   rtype           = "A"
#   scope           = "PRIVATE"
#   view_id         = data.oci_dns_views.private_view.views[0].id

#   items {
#     domain = each.key
#     rdata  = each.value
#     rtype  = "A"
#     ttl    = 300
#   }
# }

# # ロードバランサ用のAレコードを作成
# resource "oci_dns_rrset" "lb_a_records" {
#   count = length(local.target_lb_object) == 1 ? 1 : 0

#   zone_name_or_id = oci_dns_zone.private_zone.id
#   domain          = "graphql.dev.${oci_dns_zone.private_zone.name}"
#   rtype           = "A"
#   scope           = "PRIVATE"
#   view_id         = data.oci_dns_views.private_view.views[0].id

#   items {
#     domain = "graphql.dev.${oci_dns_zone.private_zone.name}"
#     rdata  = local.target_lb_object[0].ip_addresses[0]
#     rtype  = "A"
#     ttl    = 300
#   }
# }
