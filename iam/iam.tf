resource "oci_identity_group" "terraform_ec_service_group" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Terraformで作成したEC外販で使用する管理者グループ"
    name = "Terraform-EC-Service-Group"
}

resource "oci_identity_policy" "terraform_ec_service_policy" {
    #Required
    compartment_id = var.ec_service_compartment_ocid
    description = "Terraformで作成したEC外販で使用する管理者ポリシー"
    name = "Terraform-EC-Service-Policy"
    statements = [
        "Allow group Terraform-EC-Service-Group to manage all-resources in compartment id ${var.ec_service_compartment_ocid}"
    ]
}

resource "oci_identity_group" "terraform_ec_service_read_group" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Terraformで作成したEC外販で使用する運用・保守グループ"
    name = "Terraform-EC-Service-Read-Group"
}

resource "oci_identity_policy" "terraform_ec_service_read_policy" {
    #Required
    compartment_id = var.ec_service_compartment_ocid
    description = "Terraformで作成したEC外販で使用する運用・保守ポリシー"
    name = "Terraform-EC-Service-Read-Policy"
    statements = [
        "Allow group Terraform-EC-Service-Read-Group to read all-resources in compartment id ${var.ec_service_compartment_ocid}"
    ]
}

resource "oci_identity_group" "terraform_ec_service_testing_group" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Terraformで作成したEC外販で使用する開発環境管理者グループ"
    name = "Terraform-EC-Service-Testing-Group"
}

resource "oci_identity_policy" "terraform_ec_service_testing_policy" {
    #Required
    compartment_id = var.testing_compartment_ocid
    description = "Terraformで作成したEC外販で使用する開発環境管理者ポリシー"
    name = "Terraform-EC-Service-Testing-Policy"
    statements = [
        "Allow group Terraform-EC-Service-Testing-Group to manage all-resources in compartment id ${var.testing_compartment_ocid}"
    ]
}

resource "oci_identity_group" "terraform_ec_service_management_group" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Terraformで作成したEC外販で使用する管理用環境管理者グループ"
    name = "Terraform-EC-Service-Management-Group"
}

resource "oci_identity_policy" "terraform_ec_service_management_policy" {
    #Required
    compartment_id = var.management_compartment_ocid
    description = "Terraformで作成したEC外販で使用する管理用環境管理者ポリシー"
    name = "Terraform-EC-Service-Management-Policy"
    statements = [
        "Allow group Terraform-EC-Service-Management-Group to manage all-resources in compartment id ${var.management_compartment_ocid}"
    ]
}

resource "oci_identity_dynamic_group" "terraform_native_ingress_controller_dyn_group" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Terraformで作成したEC外販で使用するIngress Controllerダイナミックグループ"
    matching_rule = "ANY {instance.compartment.id = '${var.testing_compartment_ocid}', instance.compartment.id = '${var.management_compartment_ocid}'}"
    name = "Terraform-Native-Ingress-Controller-Dyn-Group"
}

resource "oci_identity_policy" "terraform_testing_native_ingress_controller_policy" {
    #Required
    compartment_id = var.testing_compartment_ocid
    description = "Terraformで作成したEC外販で使用するIngressコントローラー用のポリシー"
    name = "Terraform-Testing-Native-Ingress-Controller-Policy"
    statements = [
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage load-balancers in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to use virtual-network-family in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage cabundles in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage cabundle-associations in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage leaf-certificates in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read leaf-certificate-bundles in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage leaf-certificate-versions in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage certificate-associations in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read certificate-authorities in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage certificate-authority-associations in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read certificate-authority-bundles in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read public-ips in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage floating-ips in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage waf-family in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read cluster-family in compartment id ${var.testing_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to use tag-namespaces in compartment id ${var.testing_compartment_ocid}"
    ]
}

resource "oci_identity_policy" "terraform_management_native_ingress_controller_policy" {
    #Required
    compartment_id = var.management_compartment_ocid
    description = "Terraformで作成したEC外販で使用するIngressコントローラー, thanos用のポリシー"
    name = "Terraform-Management-Native-Ingress-Controller-Policy"
    statements = [
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage load-balancers in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to use virtual-network-family in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage cabundles in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage cabundle-associations in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage leaf-certificates in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read leaf-certificate-bundles in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage leaf-certificate-versions in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage certificate-associations in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read certificate-authorities in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage certificate-authority-associations in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read certificate-authority-bundles in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read public-ips in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage floating-ips in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage waf-family in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read cluster-family in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to use tag-namespaces in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to read buckets in compartment id ${var.management_compartment_ocid}",
        "Allow dynamic-group Native-Ingress-Controller-Dyn-Group to manage objects in compartment id ${var.management_compartment_ocid}"
    ]
}

resource "oci_identity_policy" "terraform_oke_service_policy" {
    #Required
    compartment_id = var.testing_compartment_ocid
    description = "Terraformで作成したOKEサービスで使用するポリシー"
    name = "Terraform-OKE-Service-Policy"
    statements = [
        "Allow service OKE to manage all-resources in compartment id ${var.testing_compartment_ocid}"
    ]
}