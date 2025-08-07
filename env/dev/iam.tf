resource "oci_identity_group" "ec_service_dev_group" {
  #Required
  compartment_id = var.tenancy_ocid
  description    = "Terraformで作成したEC外販で使用する開発環境管理者グループ"
  name           = "EC-Service-Dev-Group"
}

resource "oci_identity_policy" "ec_service_dev_policy" {
  #Required
  compartment_id = var.compartment_ocid
  description    = "Terraformで作成したEC外販で使用する開発環境管理者ポリシー"
  name           = "EC-Service-Dev-Policy"
  statements = [
    "Allow group EC-Service-Dev-Group to manage all-resources in compartment id ${var.compartment_ocid}"
  ]
}

resource "oci_identity_dynamic_group" "dev_native_ingress_controller_dyn_group" {
  #Required
  compartment_id = var.tenancy_ocid
  description    = "Terraformで作成したEC外販で使用するIngress Controllerダイナミックグループ"
  matching_rule  = "ALL{instance.compartment.id = '${var.compartment_ocid}'}"
  name           = "Dev-Native-Ingress-Controller-Dyn-Group"
}

resource "oci_identity_policy" "dev_native_ingress_controller_policy" {
  #Required
  compartment_id = var.compartment_ocid
  description    = "Terraformで作成したEC外販で使用するIngressコントローラー用のポリシー"
  name           = "Dev-Native-Ingress-Controller-Policy"
  statements = [
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage load-balancers in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to use virtual-network-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage cabundles in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage cabundle-associations in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage leaf-certificates in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to read leaf-certificate-bundles in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage leaf-certificate-versions in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage certificate-associations in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to read certificate-authorities in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage certificate-authority-associations in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to read certificate-authority-bundles in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to read public-ips in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage floating-ips in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to manage waf-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to read cluster-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group Dev-Native-Ingress-Controller-Dyn-Group to use tag-namespaces in compartment id ${var.compartment_ocid}"
  ]
}

resource "oci_identity_policy" "dev_oke_service_policy" {
  #Required
  compartment_id = var.compartment_ocid
  description    = "Terraformで作成したOKEサービスで使用するポリシー"
  name           = "Dev-OKE-Service-Policy"
  statements = [
    "Allow service OKE to manage all-resources in compartment id ${var.compartment_ocid}"
  ]
}
