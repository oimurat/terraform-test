# resource "oci_core_instance" "ubuntu_instance" {
#     # Required
#     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
#     compartment_id = var.compartment_ocid
#     shape = "VM.Standard2.1"
#     source_details {
#         source_id = var.instance_image_ocid
#         source_type = "image"
#     }

#     # Optional
#     display_name = "terraform-instance"
#     create_vnic_details {
#         assign_public_ip = true
#         subnet_id = var.subnet_ocid
#     }
#     preserve_boot_volume = false
# }