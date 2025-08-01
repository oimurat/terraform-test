module "registry_test" {
    source = "web-virtua-oci-multi-account-modules/container-registry/oci"
    version = "1.0.0"

    name           = "terraform-test-registry"
    compartment_id = var.testing_compartment_ocid
}