# WAFを作成
resource "oci_waf_web_app_firewall" "web_app_firewall" {
  #Required
  backend_type               = "LOAD_BALANCER"
  compartment_id             = var.compartment_ocid
  load_balancer_id           = var.load_balancer_ocid
  web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.web_app_firewall_policy.id

  #Optional
  display_name = "${var.env}-web-app-firewall"
}

# WAFポリシーを作成
resource "oci_waf_web_app_firewall_policy" "web_app_firewall_policy" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  display_name = "${var.env}-web-app-firewall-policy"
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
      name  = "Content-Type"
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
      name        = "test-access-control-rule"
      type        = "RETURN_HTTP_RESPONSE"

      #Optional
      condition          = "!i_contains(['JP'], connection.source.geo.countryCode)"
      condition_language = "JMESPATH"
    }
  }

  request_protection {

    #Optional
    body_inspection_size_limit_in_bytes = 8192
    rules {
      #Required
      action_name = "test-action-401"
      name        = "test-request-protection-rule"
      type        = "RETURN_HTTP_RESPONSE"
      protection_capabilities {
        #Required
        key     = "9300000"
        version = 1
      }

      #Optional
      is_body_inspection_enabled = true
      protection_capability_settings {

        #Optional
        allowed_http_methods           = ["GET", "HEAD", "POST", "OPTIONS"]
        max_http_request_header_length = 8000
        max_http_request_headers       = 25
        max_number_of_arguments        = 255
        max_single_argument_length     = 2000
        max_total_argument_length      = 64000
      }
    }
  }

  request_rate_limiting {

    #Optional
    rules {
      #Required
      action_name = "test-action-401"
      name        = "test-request-rate-limiting-rule"
      type        = "RETURN_HTTP_RESPONSE"
      configurations {
        #Required
        period_in_seconds = 1
        requests_limit    = 100

        #Optional
        action_duration_in_seconds = 0
      }
    }
  }
}
