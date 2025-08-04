
output "zone_name" {
  description = "作成されたDNSゾーンの名前"
  value       = oci_dns_zone.main.name
}

output "view_id" {
  description = "作成されたDNSビューのOCID"
  value       = oci_dns_view.main.id
}

output "created__records" {
  description = "作成されたAレコードのFQDNとIPアドレスのマップ"
  value = [for record in oci_dns_rrset.main : record.domain]
}