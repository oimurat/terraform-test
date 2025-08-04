# 1. プライベートDNSの解決範囲を定義する「ビュー」を作成
resource "oci_dns_view" "main" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.private_zone_name}-view"
}

# 2. プライベートDNSゾーン
resource "oci_dns_view" "main_view" {
  compartment_id = var.compartment_ocid
  display_name   = "my-private-view"
}

resource "oci_dns_zone" "main" {
  compartment_id = var.compartment_ocid
  name           = "ec-gaihan-development.com"
  zone_type      = "PRIMARY"

  view_id = oci_dns_view.main.id

  scope = "PRIVATE"
}

# 3. DNS Aレコード
resource "oci_dns_rrset" "main" {
  for_each = var.a_records

  zone_name_or_id = oci_dns_zone.main.id
  domain          = "${each.key}.${oci_dns_zone.main.name}"
  rtype           = "A"
  

  items {
    domain = "ec-gaihan-development.com" #ドメインを指定
    rdata  = "158.179.181.10"  # このドメイン名でアクセスさせたいサーバーのIPアドレス
    rtype  = "A"   #IPv4を指定
    ttl    = 3600  #キャッシュの有効時間/optional
 }
}



