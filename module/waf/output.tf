output "web-app-firewall-policy-OCID" {
  value = oci_waf_web_app_firewall_policy.web_app_firewall_policy.id
}

output "web-app-firewall-policy-name" {
  value = oci_waf_web_app_firewall_policy.web_app_firewall_policy.display_name
}

output "web-app-firewall-policy-state" {
  value = oci_waf_web_app_firewall_policy.web_app_firewall_policy.state
}

output "web-app-firewall-policy-time-created" {
  value = oci_waf_web_app_firewall_policy.web_app_firewall_policy.time_created
}

output "web-app-firewall-OCID" {
  value = oci_waf_web_app_firewall.web_app_firewall.id
}

output "web-app-firewall-name" {
  value = oci_waf_web_app_firewall.web_app_firewall.display_name
}

output "web-app-firewall-state" {
  value = oci_waf_web_app_firewall.web_app_firewall.state
}

output "web-app-firewall-time-created" {
  value = oci_waf_web_app_firewall.web_app_firewall.time_created
}
