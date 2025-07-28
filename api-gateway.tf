resource "oci_apigateway_gateway" "test_api_gateway" {
    #Required
    compartment_id = var.compartment_ocid
    endpoint_type = "PUBLIC"
    subnet_id = var.subnet_ocid

    #Optional
    display_name = "test-api-gateway"
}

resource "oci_apigateway_deployment" "test_deployment" {
    #Required
    compartment_id = var.compartment_ocid
    gateway_id = oci_apigateway_gateway.test_api_gateway.id
    path_prefix = "/"
    specification {

        #Optional
        # request_policies {

        #     #Optional
        #     authentication {
        #         #Required
        #         type = "JWT_AUTHENTICATION"

        #         #Optional
        #         audiences = var.deployment_specification_request_policies_authentication_audiences
        #         is_anonymous_access_allowed = var.deployment_specification_request_policies_authentication_is_anonymous_access_allowed
        #         issuers = var.deployment_specification_request_policies_authentication_issuers
        #         max_clock_skew_in_seconds = var.deployment_specification_request_policies_authentication_max_clock_skew_in_seconds
        #         public_keys {
        #             #Required
        #             type = var.deployment_specification_request_policies_authentication_public_keys_type

        #             #Optional
        #             is_ssl_verify_disabled = var.deployment_specification_request_policies_authentication_public_keys_is_ssl_verify_disabled
        #             keys {
        #                 #Required
        #                 format = var.deployment_specification_request_policies_authentication_public_keys_keys_format

        #                 #Optional
        #                 alg = var.deployment_specification_request_policies_authentication_public_keys_keys_alg
        #                 e = var.deployment_specification_request_policies_authentication_public_keys_keys_e
        #                 key = var.deployment_specification_request_policies_authentication_public_keys_keys_key
        #                 key_ops = var.deployment_specification_request_policies_authentication_public_keys_keys_key_ops
        #                 kid = var.deployment_specification_request_policies_authentication_public_keys_keys_kid
        #                 kty = var.deployment_specification_request_policies_authentication_public_keys_keys_kty
        #                 n = var.deployment_specification_request_policies_authentication_public_keys_keys_n
        #                 use = var.deployment_specification_request_policies_authentication_public_keys_keys_use
        #             }
        #             max_cache_duration_in_hours = var.deployment_specification_request_policies_authentication_public_keys_max_cache_duration_in_hours
        #             uri = var.deployment_specification_request_policies_authentication_public_keys_uri
        #         }
        #         token_auth_scheme = var.deployment_specification_request_policies_authentication_token_auth_scheme
        #         token_header = var.deployment_specification_request_policies_authentication_token_header
        #         token_query_param = var.deployment_specification_request_policies_authentication_token_query_param
        #         verify_claims {

        #             #Optional
        #             is_required = var.deployment_specification_request_policies_authentication_verify_claims_is_required
        #             key = var.deployment_specification_request_policies_authentication_verify_claims_key
        #             values = var.deployment_specification_request_policies_authentication_verify_claims_values
        #         }
        #     }
        # }
        routes {
            #Required
            backend {
                #Required
                type = "HTTP_BACKEND"
                url = "https://graphql.dev.ec-gaihan-development.com/graphql"

                #Optional
                connect_timeout_in_seconds = 10
                is_ssl_verify_disabled = true
                read_timeout_in_seconds = 10
                send_timeout_in_seconds = 10
            }
            methods = ["POST"]
            path = "/graphql"
        }
    }

    #Optional
    display_name = "test-deployment"
}