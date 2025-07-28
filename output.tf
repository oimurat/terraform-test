# output "web-app-firewall-policy-OCID" {
#   value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.id
# }

# output "web-app-firewall-policy-name" {
#   value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.display_name
# }

# output "web-app-firewall-policy-state" {
#   value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.state
# }

# output "web-app-firewall-policy-time-created" {
#   value = oci_waf_web_app_firewall_policy.test_web_app_firewall_policy.time_created
# }

# output "web-app-firewall-OCID" {
#   value = oci_waf_web_app_firewall.test_web_app_firewall.id
# }

# output "web-app-firewall-name" {
#   value = oci_waf_web_app_firewall.test_web_app_firewall.display_name
# }

# output "web-app-firewall-state" {
#   value = oci_waf_web_app_firewall.test_web_app_firewall.state
# }

# output "web-app-firewall-time-created" {
#   value = oci_waf_web_app_firewall.test_web_app_firewall.time_created
# }

output "api-gateway-OCID" {
  value = oci_apigateway_gateway.test_api_gateway.id
}

output "api-gateway-name" {
  value = oci_apigateway_gateway.test_api_gateway.display_name
}

output "api-gateway-state" {
  value = oci_apigateway_gateway.test_api_gateway.state
}

output "api-gateway-time-created" {
  value = oci_apigateway_gateway.test_api_gateway.time_created
}

output "api-gateway-deployment-OCID" {
  value = oci_apigateway_deployment.test_deployment.id
}

output "api-gateway-deployment-name" {
  value = oci_apigateway_deployment.test_deployment.display_name
}

output "api-gateway-deployment-state" {
  value = oci_apigateway_deployment.test_deployment.state
}

output "api-gateway-deployment-time-created" {
  value = oci_apigateway_deployment.test_deployment.time_created
}