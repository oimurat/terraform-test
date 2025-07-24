resource "oci_waf_web_app_firewall_policy" "test_web_app_firewall_policy" {
    #Required
    compartment_id = var.compartment_ocid



    #Optional
    actions {
        name = "test-action-check"
        type = "CHECK"
    }

    actions {
        name = "test-action-allow"
        type = "ALLOW"
    }

    actions {
        #Required
        name = "test-action-401"
        type = "RETURN_HTTP_RESPONSE"

        #Optional
        body {
            #Required
            text = "Unauthorized"
            type = "STATIC_TEXT"
        }
        code = 401
        headers {

            #Optional
            name = "Content-Type"
            value = "application/json"
        }
    }

    display_name = "test-web-app-firewall-policy"

    request_access_control {
        #Required
        default_action_name = "test-action-allow"

        #Optional
        rules {
            #Required
            action_name = "test-action-401"
            name = "test-rule-401"
            type = "BLOCK"

            #Optional
            condition = "ip.src in ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']"
            condition_language = "JMESPATH"
        }
    }
}