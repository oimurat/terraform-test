
# Outputs for compute instance

# output "public-ip-for-compute-instance" {
#   value = oci_core_instance.ubuntu_instance.public_ip
# }

# output "instance-name" {
#   value = oci_core_instance.ubuntu_instance.display_name
# }

# output "instance-OCID" {
#   value = oci_core_instance.ubuntu_instance.id
# }

# output "instance-region" {
#   value = oci_core_instance.ubuntu_instance.region
# }

# output "instance-shape" {
#   value = oci_core_instance.ubuntu_instance.shape
# }

# output "instance-state" {
#   value = oci_core_instance.ubuntu_instance.state
# }

# output "instance-OCPUs" {
#   value = oci_core_instance.ubuntu_instance.shape_config[0].ocpus
# }

# output "instance-memory-in-GBs" {
#   value = oci_core_instance.ubuntu_instance.shape_config[0].memory_in_gbs
# }

# output "time-created" {
#   value = oci_core_instance.ubuntu_instance.time_created
# }

# The "name" of the availability domain to be used for the compute instance.
output "name-of-first-availability-domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "web-app-firewall-policy-OCID" {
  value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.id
}

output "web-app-firewall-policy-name" {
  value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.display_name
}

output "web-app-firewall-policy-state" {
  value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.state
}

output "web-app-firewall-policy-time-created" {
  value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.time_created
}

output "web-app-firewall-OCID" {
  value = oci_waf_web_app_firewall.test_web_app_firewall.id
}

output "web-app-firewall-name" {
  value = oci_waf_web_app_firewall.test_web_app_firewall.display_name
}