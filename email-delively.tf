resource "oci_email_email_domain" "test_email_domain" {
    #Required
    compartment_id =  var.testing_compartment_ocid
    name = "example.co.jp"
}

resource "oci_email_sender" "test_sender" {
    #Required
    compartment_id =  var.testing_compartment_ocid
    email_address = "ec-service@example.co.jp"
}