output "api-gateway-OCID" {
  value = oci_apigateway_gateway.api_gateway.id
}

output "api-gateway-name" {
  value = oci_apigateway_gateway.api_gateway.display_name
}

output "api-gateway-state" {
  value = oci_apigateway_gateway.api_gateway.state
}

output "api-gateway-time-created" {
  value = oci_apigateway_gateway.api_gateway.time_created
}

output "deployment-OCID" {
  value = oci_apigateway_deployment.deployment.id
}

output "deployment-name" {
  value = oci_apigateway_deployment.deployment.display_name
}

output "deployment-state" {
  value = oci_apigateway_deployment.deployment.state
}

output "deployment-time-created" {
  value = oci_apigateway_deployment.deployment.time_created
}
