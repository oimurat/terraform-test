resource "oci_waf_web_app_firewall_policy" "test_web_app_firewall_policy" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    display_name = "test-web-app-firewall-policy"
}