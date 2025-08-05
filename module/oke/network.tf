
resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.env}-VCN"
}

# Gateways
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.env}-Internet-Gateway"
  vcn_id         = oci_core_vcn.this.id
}

resource "oci_core_nat_gateway" "ngw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.env}-NAT-Gateway"
  vcn_id         = oci_core_vcn.this.id
}

resource "oci_core_service_gateway" "sgw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.env}-Service-Gateway"
  vcn_id         = oci_core_vcn.this.id
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# SUBNET 1: Private Subnet for K8s API Endpoint
resource "oci_core_subnet" "Private-Subnet-For-K8-API-Endpoint" {
  cidr_block                 = var.k8apiendpoint_private_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "${var.env}-Private-Subnet-For-K8s-API-Endpoint"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-K8-API-Endpoint-Subnet.id
  security_list_ids          = [oci_core_security_list.Security-List-For-K8-APIendpoint.id]
  vcn_id                     = oci_core_vcn.this.id
}

resource "oci_core_route_table" "Route-Table-For-Private-K8-API-Endpoint-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.env}-RT-For-K8s-API-Endpoint"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw.id
  }
  route_rules {
    destination       = "all-nrt-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

resource "oci_core_security_list" "Security-List-For-K8-APIendpoint" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.env}-SL-For-K8s-API-Endpoint"

  ingress_security_rules {
    protocol    = "6"
    source      = var.workernodes_private_subnet_cidr_block
    stateless   = false
    tcp_options {
      min = 6443
      max = 6443
      }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = var.workernodes_private_subnet_cidr_block
    stateless   = false
    tcp_options {
      min = 12250
      max = 12250
      }
  }

  egress_security_rules {
    destination = var.workernodes_private_subnet_cidr_block
    protocol    = "all"
    stateless   = false
  }
  egress_security_rules {
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      min = 443
      max = 443
      }
  }
}

# SUBNET 2: Private Subnet For Worker Nodes
resource "oci_core_subnet" "Private-Subnet-For-Worker-Nodes" {
  cidr_block                 = var.workernodes_private_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "${var.env}-Private-Subnet-For-Worker-Nodes"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-Subnet-For-Worker-Nodes.id
  security_list_ids          = [oci_core_security_list.Security-List-For-Private-Subnet-For-Worker-Nodes.id]
  vcn_id                     = oci_core_vcn.this.id
}

resource "oci_core_route_table" "Route-Table-For-Private-Subnet-For-Worker-Nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.env}-RT-For-Worker-Nodes"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw.id
  }
}

resource "oci_core_security_list" "Security-List-For-Private-Subnet-For-Worker-Nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.env}-SL-For-Worker-Nodes"

  ingress_security_rules {
    protocol    = "all"
    source      = var.workernodes_private_subnet_cidr_block
    stateless   = false
  }
  ingress_security_rules {
    protocol    = "all"
    source      = var.k8apiendpoint_private_subnet_cidr_block
    stateless   = false
  }
  ingress_security_rules {
    protocol    = "all"
    source      = var.serviceloadbalancers_public_subnet_cidr_block
    stateless   = false
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# SUBNET 3: Public Subnet For Load Balancers
resource "oci_core_subnet" "Public-Subnet-For-Load-Balancers" {
  cidr_block                 = var.serviceloadbalancers_public_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = "${var.env}-Public-Subnet-For-Load-Balancers"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.Route-Table-For-Public-Load-Balancers-Subnet.id
  security_list_ids          = [oci_core_security_list.Security-List-For-Public-Load-Balancers-Subnet.id]
  vcn_id                     = oci_core_vcn.this.id
}

resource "oci_core_route_table" "Route-Table-For-Public-Load-Balancers-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.env}-RT-For-Load-Balancers"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_security_list" "Security-List-For-Public-Load-Balancers-Subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.env}-SL-For-Load-Balancers"

  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false
  }

  egress_security_rules {
    destination = var.workernodes_private_subnet_cidr_block
    protocol    = "6" # TCP
    stateless   = false
    tcp_options {
      min = 30000
      max = 32767
    }
  }
}