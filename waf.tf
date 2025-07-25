resource "oci_waf_web_app_firewall_policy" "test_web_app_firewall_policy" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    display_name = "test-web-app-firewall-policy"
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
            text = "{\"code\":\"401\",\"message\":\"Unauthorized\"}"
            type = "STATIC_TEXT"
        }
        code = 401
        headers {

            #Optional
            name = "Content-Type"
            value = "application/json"
        }
    }

    request_access_control {
        #Required
        default_action_name = "test-action-allow"

        #Optional
        rules {
            #Required
            action_name = "test-action-401"
            name = "test-access-control-rule"
            type = "ACCESS_CONTROL"

            #Optional
            condition = "!i_contains(['JP'], connection.source.geo.countryCode)"
            condition_language = "JMESPATH"
        }
    }

    request_protection {

        #Optional
        body_inspection_size_limit_in_bytes = 8192
        rules {
            #Required
            action_name = "test-action-401"
            name = "test-request-protection-rule"
            type = "PROTECTION"
            protection_capabilities {
                #Required
                key = "9300000"
                version = 1
            }

            #Optional
            is_body_inspection_enabled = true
            protection_capability_settings {

                #Optional
                allowed_http_methods = ["GET", "HEAD", "POST", "OPTIONS"]
                max_http_request_header_length = 8000
                max_http_request_headers = 25
                max_number_of_arguments = 255
                max_single_argument_length = 2000
                max_total_argument_length = 64000
            }
        }
    }
}