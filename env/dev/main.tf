module "waf" {
  source = "../../module/waf"
  env = var.env
  testing_compartment_ocid = var.testing_compartment_ocid
  testing_load_balancer_ocid = var.testing_load_balancer_ocid
}