module "waf" {
  source = "../../module/waf"
  env = var.env
  compartment_ocid = var.compartment_ocid
  load_balancer_ocid = var.load_balancer_ocid
}