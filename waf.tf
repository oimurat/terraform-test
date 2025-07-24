resource "oci_waf_web_app_firewall_policy" "test_web_app_firewall_policy" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    actions {
        #Required
        name = "test-action"
        type = "RETURN_HTTP_RESPONSE"

        #Optional
        body {
            #Required
            text = "Unauthorized"
            type = "application/json"
        }
        code = 401
        headers {

            #Optional
            name = "Content-Type"
            value = "application/json"
        }
    }
    display_name = "test-web-app-firewall-policy"
}