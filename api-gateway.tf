resource "oci_apigateway_gateway" "test_gateway" {
    #Required
    compartment_id = var.compartment_ocid
    endpoint_type = "PUBLIC"
    subnet_id = var.subnet_ocid

    #Optional
    display_name = "test-api-gateway"
}

