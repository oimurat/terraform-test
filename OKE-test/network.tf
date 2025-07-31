###########################################################################
# Terraform module: VCN, Gateways, Default networks and Subnet Resources. #
#                                                                         #
# Copyright (c) 2024 Oracle        Author: Mahamat H. Guiagoussou         #
###########################################################################

###########################################################################
# Network - This configuration is a simplified Networking Flat module     #
#                                                                         #
# Core VCN: Virtual Cloud Network for the OKE Cluster                     #
# Gateways: Internet Gateway, NAT Gateway and All OCI Service Gateways    #
# Other: Default Routing Table and Default Security List                  #
###########################################################################

# Core VCN
resource "oci_core_vcn" "this" {
  count = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.display_name_prefix}-VCN"
  dns_label      = var.host_name_prefix
}

# Gateways
resource "oci_core_internet_gateway" "igw" {
  count          = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-Internet-Gateway"
  vcn_id         = oci_core_vcn.this[0].id
}

resource "oci_core_nat_gateway" "ngw" {
  count          = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-NAT-Gateway"
  vcn_id         = oci_core_vcn.this[0].id
}

resource "oci_core_service_gateway" "sgw" {
  count          = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-Service-Gateway"
  vcn_id         = oci_core_vcn.this[0].id
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
  count                      = var.is_vcn_created ? 1 : 0
  cidr_block                 = var.k8apiendpoint_private_subnet_cidr_block
  compartment_id             = var.compartment_id
  display_name               = "${var.display_name_prefix}-Private-Subnet-For-K8s-API-Endpoint"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-K8-API-Endpoint-Subnet[0].id
  security_list_ids          = [oci_core_security_list.Security-List-For-K8-APIendpoint[0].id]
  vcn_id                     = oci_core_vcn.this[0].id
}

resource "oci_core_route_table" "Route-Table-For-Private-K8-API-Endpoint-Subnet" {
  count        = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-RT-For-K8s-API-Endpoint"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw[0].id
  }
  route_rules {
    destination       = "all-nrt-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw[0].id
  }
}

resource "oci_core_security_list" "Security-List-For-K8-APIendpoint" {
  count          = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-SL-For-K8s-API-Endpoint"
  
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
  count                      = var.is_vcn_created ? 1 : 0
  cidr_block                 = var.workernodes_private_subnet_cidr_block
  compartment_id             = var.compartment_id
  display_name               = "${var.display_name_prefix}-Private-Subnet-For-Worker-Nodes"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.Route-Table-For-Private-Subnet-For-Worker-Nodes[0].id
  security_list_ids          = [oci_core_security_list.Security-List-For-Private-Subnet-For-Worker-Nodes[0].id]
  vcn_id                     = oci_core_vcn.this[0].id
}

resource "oci_core_route_table" "Route-Table-For-Private-Subnet-For-Worker-Nodes" {
  count        = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-RT-For-Worker-Nodes"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw[0].id
  }
}

resource "oci_core_security_list" "Security-List-For-Private-Subnet-For-Worker-Nodes" {
  count          = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-SL-For-Worker-Nodes"

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
  count                      = var.is_vcn_created ? 1 : 0
  cidr_block                 = var.serviceloadbalancers_public_subnet_cidr_block
  compartment_id             = var.compartment_id
  display_name               = "${var.display_name_prefix}-Public-Subnet-For-Load-Balancers"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.Route-Table-For-Public-Load-Balancers-Subnet[0].id
  security_list_ids          = [oci_core_security_list.Security-List-For-Public-Load-Balancers-Subnet[0].id]
  vcn_id                     = oci_core_vcn.this[0].id
}

resource "oci_core_route_table" "Route-Table-For-Public-Load-Balancers-Subnet" {
  count        = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-RT-For-Load-Balancers"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw[0].id
  }
}

resource "oci_core_security_list" "Security-List-For-Public-Load-Balancers-Subnet" {
  count          = var.is_vcn_created ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-SL-For-Load-Balancers"

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


/*

# Core VCN
resource "oci_core_vcn" "this" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.display_name_prefix}-VCN"
  dns_label      = var.host_name_prefix
}


# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-Internet-Gateway"
  enabled        = "true"
  vcn_id         = oci_core_vcn.this.*.id[0]
}


# NAT Gateway
resource "oci_core_nat_gateway" "ngw" {
  count        = (var.is_vcn_created) ? 1 : 0
  display_name   = "${var.display_name_prefix}-NAT-Gateway"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]
}


# All OCI Services Data Source
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


# Service Gateway
resource "oci_core_service_gateway" "sgw" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }

  display_name = "${var.display_name_prefix}-Service-Gateway"
  vcn_id       = oci_core_vcn.this.*.id[0]

}



# Default Routing Table
resource "oci_core_default_route_table" "test_route_table" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id             = var.compartment_id
  display_name               = "${var.display_name_prefix}-Default-RoutingTable"
  manage_default_resource_id = oci_core_vcn.this.*.default_route_table_id[0]
  route_rules {
    description       = "Route Rule for ${var.display_name_prefix} Default Route Table"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.*.id[0]
  }
}



# Default DHCP Options
resource "oci_core_default_dhcp_options" "Default-DHCP-Options" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id             = var.compartment_id
  display_name               = "${var.display_name_prefix}-Default-DHCP-Options"
  domain_name_type           = "CUSTOM_DOMAIN"
  manage_default_resource_id = oci_core_vcn.this.*.default_dhcp_options_id[0]
  options {
    custom_dns_servers = []
    server_type        = "VcnLocalPlusInternet"
    type               = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "${var.host_name_prefix}core.oraclevcn.com"
    ]
    type = "SearchDomain"
  }
}


# Default Security List
resource "oci_core_default_security_list" "Default-Security-List" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id

  display_name = "${var.display_name_prefix}-Default-Security-List"

  egress_security_rules {
    description      = "Egress Open to all protocols"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  manage_default_resource_id = oci_core_vcn.this.*.default_security_list_id[0]
}



#########################################################################
# SUBNETS - This configuration is a Root/Flat networking module         #
#                                                                       #
# Subnet 1: Private Subnet for K8 API Endpoint Subnet                   #
# Subnet 2: Private Subnet For Worker Nodes                             #
# Subnet 3: Public Subnet For Load Balancers                            #
#                                                                       #
# For each Subnet the code includes:                                    #
#     (1) The Subnets definition (Private or Public)                     #
#     (2) A corresponding Route Table                                   #
#     (3) A corresponding Security List                                 #
#########################################################################


# Private Subnet for K8 API Endpoint Subnet
# Subnet 1: Private Subnet for K8 API Endpoint Subnet                   #
#-----------------------------------------------------
resource "oci_core_subnet" "Private-Subnet-For-K8-API-Endpoint" {
  count = (var.is_vcn_created) ? 1 : 0

  cidr_block                 = var.k8apiendpoint_private_subnet_cidr_block
  compartment_id             = var.compartment_id
  dhcp_options_id            = oci_core_vcn.this.*.default_dhcp_options_id[0]
  display_name               = "${var.display_name_prefix}-Private-Subnet-For-Kubernetes-API-Endpoint"
  dns_label                  = "${var.host_name_prefix}k8pubnetep"
  ipv6cidr_blocks            = []
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.Route-Table-For-Private-K8-API-Endpoint-Subnet.*.id[0]
  security_list_ids = [
    oci_core_security_list.Security-List-For-K8-APIendpoint.*.id[0],
  ]
  vcn_id = oci_core_vcn.this.*.id[0]
}


# Routing Table For Public K8 API Endpoint Subnet
resource "oci_core_route_table" "Route-Table-For-Private-K8-API-Endpoint-Subnet" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]

  display_name = "${var.display_name_prefix}-RoutingTable-For-Private-K8-API-Endpoint-Subnet"
  route_rules {
    description       = "Route Table for ${var.display_name_prefix} For Private K8 API Endpoint Subnet through NAT"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.ngw.*.id[0]
  }

  route_rules {
    description       = "Route Table for ${var.display_name_prefix} For Private K8 API Endpoint Subnet through SGW"
    destination       = "all-nrt-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.*.id[0]
  }

}



# Security List For K8 API Endpoint
resource "oci_core_security_list" "Security-List-For-K8-APIendpoint" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]

  display_name = "${var.display_name_prefix}-Security-List-For-K8-API-Endpoint"

  # Ingress Rules (入口)
  ingress_security_rules {
    description = "Allow Worker Nodes to K8s API Endpoint"
    protocol    = "6" # TCP
    source      = var.workernodes_private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      min = 6443
      max = 6443
    }
  }
  ingress_security_rules {
    description = "Allow Worker Nodes to K8s control plane"
    protocol    = "6" # TCP
    source      = var.workernodes_private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  # Egress Rules (出口)
  egress_security_rules {
    description      = "Allow K8s API Endpoint to Worker Nodes"
    destination      = var.workernodes_private_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
  egress_security_rules {
    description      = "Allow K8s API Endpoint to OCI Services"
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    tcp_options {
      min = 443
      max = 443
    }
  }
}
/*
  # ------------- #
  # Ingress Rules
  # --------------#

  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API Endpoint communication."
    protocol    = "6"
    source      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }


  ingress_security_rules {
    description = "   Kubernetes worker to control plane communication."
    protocol    = "6"
    source      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }


  ingress_security_rules {
    description = "Path Discovery."
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }


  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API Endpoint communication."
    protocol    = "6"
    source      = var.workernodes_private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  ingress_security_rules {
    description = "Bastion host to Kubernetes API Endpoint communication."
    protocol    = "6"
    source      = var.bastion_public_subnet_cidr_block # 10.0.3.0/24
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }


  # ------------ #
  # Egress Rules #
  # ------------ #

  egress_security_rules {
    description      = "Allow Kubernetes control plane to communicate with OKE."
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }


  egress_security_rules {
    description = "Path Discovery."
    icmp_options {
      code = "4"
      type = "3"
    }
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "1"
    stateless        = "false"
  }


  egress_security_rules {
    description      = " Allow Kubernetes control plane to communicate with worker nodes."
    destination      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }


  egress_security_rules {
    description = "Path Discovery."
    icmp_options {
      code = "4"
      type = "3"
    }
    destination      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    destination_type = "CIDR_BLOCK"
    protocol         = "1"
    stateless        = "false"
  }

}
*/
/*
# Private Subnet For Worker Nodes
resource "oci_core_subnet" "Private-Subnet-For-Worker-Nodes" {
  count = (var.is_vcn_created) ? 1 : 0

  cidr_block                   = var.workernodes_private_subnet_cidr_block
  compartment_id               = var.compartment_id
  dhcp_options_id              = oci_core_vcn.this[0].default_dhcp_options_id
  display_name                 = "${var.display_name_prefix}-Private-Subnet-For-Worker-Nodes"
  dns_label                    = "${var.host_name_prefix}wnprvnet"
  prohibit_public_ip_on_vnic   = true
  route_table_id               = oci_core_route_table.Route-Table-For-Private-Subnet-For-Worker-Nodes[0].id
  security_list_ids = [
    oci_core_security_list.Security-List-For-Private-Subnet-For-Worker-Nodes[0].id
  ]
  vcn_id = oci_core_vcn.this[0].id
}
*/
/*
# Private Subnet For Worker Nodes
# Subnet 2: Private Subnet For Worker Nodes                             #
#-------------------------------------------
resource "oci_core_subnet" "Private-Subnet-For-Worker-Nodes" {
  count = (var.is_vcn_created) ? 1 : 0

  cidr_block                   = var.workernodes_private_subnet_cidr_block
  compartment_id               = var.compartment_id
  dhcp_options_id              = oci_core_vcn.this.*.default_dhcp_options_id[0]
  display_name                 = "${var.display_name_prefix}-Private-Subnet-For-Worker-Nodes"
  dns_label                    = "${var.host_name_prefix}wnprvnet"
  ipv6cidr_blocks              = []
  prohibit_internet_ingress    = "true"
  prohibit_public_ip_on_vnic   = "true"
  route_table_id               = oci_core_route_table.Route-Table-For-Private-Subnet-For-Worker-Nodes.*.id[0]
  security_list_ids = [
    oci_core_security_list.Security-List-For-Private-Subnet-For-Worker-Nodes.*.id[0]
  ]
  vcn_id = oci_core_vcn.this.*.id[0]
}
*/
/*
# Private Subnet Security List For Private Subnet For Worker Nodes
resource "oci_core_security_list" "Security-List-For-Private-Subnet-For-Worker-Nodes" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.display_name_prefix}-Private-Subnet-For-Worker-Nodes"

  # Ingress Rules (入口)
  ingress_security_rules {
    description = "Allow pod-to-pod communication"
    protocol    = "all"
    source      = var.workernodes_private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
  ingress_security_rules {
    description = "Allow K8s API Endpoint to Worker Nodes"
    protocol    = "all"
    source      = var.k8apiendpoint_private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
  ingress_security_rules {
    description = "Allow Load Balancer to Worker Nodes"
    protocol    = "all" # For NodePorts and Health Checks
    source      = var.serviceloadbalancers_public_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
  }

  # Egress Rules (出口)
  egress_security_rules {
    description      = "Allow Worker Nodes to K8s API Endpoint"
    destination      = var.k8apiendpoint_private_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
  egress_security_rules {
    description      = "Allow Worker Nodes to anywhere on the Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
}
*/

/*
# Routing Table For Private Subnet For Worker Nodes
resource "oci_core_route_table" "Route-Table-For-Private-Subnet-For-Worker-Nodes" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]

  display_name = "${var.display_name_prefix}-RoutingTable-For-Private-Subnet-For-Worker-Nodes"

  route_rules {
    description       = "Route Rule for Internet-bound traffic through the NAT Gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.ngw.*.id[0]
  }

  route_rules {
    description       = "Route Rule for Oracle Services through the Service Gateway"
    destination       = "all-nrt-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.*.id[0]
  }

}

/*
# Private Subnet Security List For Private Subnet For Worker Nodes
resource "oci_core_security_list" "Security-List-For-Private-Subnet-For-Worker-Nodes" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]

  display_name = "${var.display_name_prefix}-Security-List-For-Private-Subnet-For-Worker-Nodes"


  # ------------- #
  # Ingress Rules #
  # ------------- #

  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes."
    protocol    = "all"
    source      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }


  ingress_security_rules {
    description = "Allow Kubernetes control plane to communicate with worker nodes."
    protocol    = "6"
    source      = var.k8apiendpoint_private_subnet_cidr_block # "10.0.0.0/30"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }


  ingress_security_rules {
    description = "Path Discovery."
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }


  ingress_security_rules {
    description = "Allow inbound SSH traffic to managed nodes."
    protocol    = "6"
    source      = var.bastion_public_subnet_cidr_block # "10.0.3.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    description = "Load balancer to worker nodes node ports."
    protocol    = "6"
    source      = var.serviceloadbalancers_public_subnet_cidr_block # "10.0.2.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "32767"
      min = "30000"
    }
  }


  ingress_security_rules {
    description = "Load balancer to worker nodes node ports."
    protocol    = "17"
    source      = var.serviceloadbalancers_public_subnet_cidr_block # "10.0.2.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    udp_options {
      max = "32767"
      min = "30000"
    }
  }


  ingress_security_rules {
    description = "Allow load balancer to communicate with kube-proxy on worker nodes."
    protocol    = "6"
    source      = var.serviceloadbalancers_public_subnet_cidr_block # "10.0.2.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "10256"
      min = "10256"
    }
  }


  ingress_security_rules {
    description = "Allow load balancer to communicate with kube-proxy on worker nodes."
    protocol    = "17"
    source      = var.serviceloadbalancers_public_subnet_cidr_block # "10.0.2.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    udp_options {
      max = "10256"
      min = "10256"
    }
  }


  # ------------ #
  # Egress Rules #
  # ------------ #

  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes."
    destination      = var.workernodes_private_subnet_cidr_block # 10.0.1.0/24
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }


  egress_security_rules {
    description      = "Allow worker nodes to communicate with OKE."
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "Kubernetes worker to Kubernetes API endpoint communication (TCP)."
    destination      = var.k8apiendpoint_private_subnet_cidr_block # 10.0.0.0/30
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }


  egress_security_rules {
    description      = "Kubernetes worker to Kubernetes API endpoint communication (UDP)."
    destination      = var.k8apiendpoint_private_subnet_cidr_block # 10.0.0.0/30
    destination_type = "CIDR_BLOCK"
    protocol         = "17"
    stateless        = "false"
    udp_options {
      max = "6443"
      min = "6443"
    }
  }


  egress_security_rules {
    description      = "Kubernetes worker to control plane communication (TCP)."
    destination      = var.k8apiendpoint_private_subnet_cidr_block # 10.0.0.0/30
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication (UDP)."
    destination      = var.k8apiendpoint_private_subnet_cidr_block # 10.0.0.0/30
    destination_type = "CIDR_BLOCK"
    protocol         = "17"
    stateless        = "false"
    udp_options {
      max = "12250"
      min = "12250"
    }
  }


  egress_security_rules {
    description      = "Allow worker nodes to communicate with internet."
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }


}


# Private Subnet Security List For Private Subnet For Worker Nodes
resource "oci_core_security_list" "Security-List-For-Private-Subnet-For-Worker-Nodes" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id

  display_name = "${var.display_name_prefix}-Security-List-For-Private-Subnet-For-Worker-Nodes"


  # ------------- #
  # Ingress Rules # (イングレスルール：入口)
  # ------------- #

  # 他のワーカーノードからの通信を許可
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes."
    protocol    = "all"
    source      = var.workernodes_private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  # コントロールプレーンからの通信を許可
  ingress_security_rules {
    description = "Allow Kubernetes control plane to communicate with worker nodes."
    protocol    = "6"
    source      = var.serviceloadbalancers_public_subnet_cidr_block # ★コントロールプレーンのいる場所
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  # ロードバランサーからの通信を許可
  ingress_security_rules {
    description = "Load balancer to worker nodes node ports."
    protocol    = "6"
    source      = var.serviceloadbalancers_public_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "32767"
      min = "30000"
    }
  }


  # ------------ #
  # Egress Rules # (エグレスルール：出口)
  # ------------ #

  # 他のワーカーノードへの通信を許可
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes."
    destination      = var.workernodes_private_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }

  # ★★★★★ ここが最も重要な修正箇所です ★★★★★
  # コントロールプレーンへの通信を許可
  egress_security_rules {
    description      = "Kubernetes worker to Kubernetes API endpoint communication."
    destination      = var.serviceloadbalancers_public_subnet_cidr_block # ★コントロールプレーンがいるパブリックサブネットを指定
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  # OCIサービスへの通信を許可
  egress_security_rules {
    description      = "Allow worker nodes to communicate with OCI Services."
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
}


# Regional Public Subnet for Service Load Balancers
resource "oci_core_subnet" "Public-Subnet-For-Load-Balancers" {
  count = (var.is_vcn_created) ? 1 : 0

  cidr_block                   = var.serviceloadbalancers_public_subnet_cidr_block
  compartment_id               = var.compartment_id
  dhcp_options_id              = oci_core_vcn.this.*.default_dhcp_options_id[0]
  display_name                 = "${var.display_name_prefix}-Public-Subnet-For-Load-Balancers"
  dns_label                    = "${var.host_name_prefix}slbpubnet"
  ipv6cidr_blocks              = []
  prohibit_internet_ingress    = "false"
  prohibit_public_ip_on_vnic   = "false"
  route_table_id               = oci_core_route_table.Route-Table-For-Public-Load-Balancers-Subnet.*.id[0]
  security_list_ids = [
    oci_core_security_list.Security-List-For-Public-Load-Balancers-Subnet.*.id[0],
  ]
  vcn_id = oci_core_vcn.this.*.id[0]
}


# Routing Table For Public Load Balancers Subnet
resource "oci_core_route_table" "Route-Table-For-Public-Load-Balancers-Subnet" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]

  display_name = "${var.display_name_prefix}-RoutingTable-For-Public-Load-Balancers-Subnet"
  route_rules {
    description       = "Route Table for ${var.display_name_prefix} Route Rule For Public Load Balancers Subnet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.*.id[0]
  }
}


# Security List for Public Load Balancers Subnet
# Subnet 3: Public Subnet For Load Balancers                            #
#---------------------------------------------
resource "oci_core_security_list" "Security-List-For-Public-Load-Balancers-Subnet" {
  count = (var.is_vcn_created) ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.*.id[0]

  display_name = "${var.display_name_prefix}-Security-List-For-Public-Load-Balancers-Subnet"
  

  # Ingress Rules (入口)
  ingress_security_rules {
    description = "Allow Internet to Load Balancer Listeners"
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
  }

  # Egress Rules (出口)
  egress_security_rules {
    description      = "Allow Load Balancer to Worker Nodes (NodePorts)"
    destination      = var.workernodes_private_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    tcp_options {
      min = 30000
      max = 32767
    }
  }
  egress_security_rules {
    description      = "Allow Load Balancer to Worker Nodes (Health Check)"
    destination      = var.workernodes_private_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "6" # TCP
    stateless        = false
    tcp_options {
      min = 10256
      max = 10256
    }
  }
}
*/
 /*
  # ------------- #
  # Ingress Rules #
  # ------------- #

  ingress_security_rules {
    description = "Load balancer listener protocol and port. Customize as required (e.g.: TCP from Internet) on port 443"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "443"
      min = "443"
      source_port_range {
        max = "443"
        min = "443"
      }
    }
  }


  ingress_security_rules {
    description = "Load balancer listener protocol and port. Customize as required (e.g.: TCP from Internet) on port 8080)"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "8080"
      min = "8080"
      source_port_range {
        max = "8080"
        min = "8080"
      }
    }
  }


  ingress_security_rules {
    description = "Load balancer listener protocol and port 80. Customize as required (e.g.: TCP from Internet)"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "80"
      min = "80"
      source_port_range {
        max = "80"
        min = "80"
      }
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    description = "Load balancer listener protocol and port. Customize as required (e.g.: UDP from Internet) on port 443"
    protocol    = "17"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    udp_options {
      max = "443"
      min = "443"
      source_port_range {
        max = "443"
        min = "443"
      }
    }
  }
  
  ingress_security_rules {
    description = "Allow Internet to Load Balancer Listeners"
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
  }



  # ------------ #
  # Egress Rules #
  # ------------ #

  egress_security_rules {
    description      = "Load balancer to worker nodes node ports."
    destination      = var.workernodes_private_subnet_cidr_block # "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
    tcp_options {
      max = "32767"
      min = "30000"
    }
  }


  egress_security_rules {
    description      = "Allow load balancer to communicate with kube-proxy on worker nodes. [TCP Port Range: 30000-32767]"
    destination      = var.workernodes_private_subnet_cidr_block # "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
    tcp_options {
      max = "10256"
      min = "10256"
    }
  }


  egress_security_rules {
    description      = "Allow load balancer to communicate with kube-proxy on worker nodes."
    destination      = var.workernodes_private_subnet_cidr_block # "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "17"
    stateless        = "false"
    udp_options {
      max = "32767"
      min = "30000"
    }
  }

  egress_security_rules {
    description      = "Allow load balancer to communicate with kube-proxy on worker nodes."
    destination      = var.workernodes_private_subnet_cidr_block # "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "17"
    stateless        = "false"
    udp_options {
      max = "10256"
      min = "10256"
    }
  }

  lifecycle {
    ignore_changes = [ingress_security_rules, egress_security_rules]
  }


}
*/