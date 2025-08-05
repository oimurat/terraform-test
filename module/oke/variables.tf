#####################################################################################
# Terraform module: Default Variables Definitions for Oracle Resource Manager (ORM) #
#                                                                        	        	#
# Copyright (c) 2025 Oracle        Author: Mahamat H. Guiagoussou and Payal Sharma  #
#####################################################################################


# OCI Provider Attributes

variable "tenancy_ocid" {
  description = "Tenancy ID where to create resources"
  type        = string
}


variable "region" {
  description = "OCI Region where resources will be deployed"
  type        = string
  default     = "ap-tokyo-1" # 東京リージョン
}


# Comment Out if using ORM

variable "fingerprint" {
  description = "Fingerprint of OCI API private key for Tenancy"
  type        = string
}


variable "private_key_path" {
  description = "Path to OCI API private key used for Tenancy"
  type        = string
}


variable "user_ocid" {
  description = "User OCID that Terraform will use to create resources for Tenancy"
  type        = string
}

# End Comment Out


# Compartment
variable "compartment_id" {
  description = "OCID of the compartment where resources will be created"
}


variable "display_name_prefix" {
  description = "Descriptive name prefix for all test resources."
}


variable "host_name_prefix" {
  description = "Descriptive name prefix for the host."
}


# Networking 
variable "is_vcn_created" {
  description = "Boolean variable to specify whether VCN is created by terraform or manually."
  default     = false
}


# Networking Resources

variable "vcn_cidr_block" {
  description = "Core VCN CIDR Block"
  default     = "10.0.0.0/16"
}


variable "k8apiendpoint_private_subnet_cidr_block" {
  description = "Kubernetes API Endpoint Private Subnet CIDR Block"
  default     = "10.0.0.0/28"
}

variable "workernodes_private_subnet_cidr_block" {
  description = "Worker Nodes API Endpoint Private Subnet CIDR Block"
  default     = "10.0.10.0/24"
}

variable "serviceloadbalancers_public_subnet_cidr_block" {
  description = "service Load Balancers Public Subnet CIDR Block"
  default     = "10.0.20.0/24"
}

variable "bastion_public_subnet_cidr_block" {
  description = "Bastion Public Subnet CIDR Block"
  default     = "10.0.30.0/24"
}
variable "pod_network_cidr" {
  description = "Bastion Public Subnet CIDR Block"
  default     = "10.0.10.0/24"
}


# Regions Keys Map

variable "image_ids" {
  description = "OCI Region <--> Compute Image OCID"
  type        = map(string)
  default = {
    "ap-tokyo-1"   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaayciyuq2akqdjmoxv444besgde5tbkcskcbj5dhewjnwhqqplnnq"
  #  "us-phoenix-1" = "ocid1.image.oc1.phx.aaaaaaaahgrs3zcwrvutjtni557ttrt62uggseijsmqxacr7dym423uaokcq"
  #  "us-ashburn-1" = "ocid1.image.oc1.iad.aaaaaaaal5ocygrbx2lfvrnugr6yqlskpomeww6d7pqb3zes2pzho3td4gcq" 
  #  # Add more regions as needed
  }
}



# OKE variables

# Create an OKE Cluster
variable "is_k8cluster_created" {
  description = "Boolean variable to specify whether to create an OKE cluster or not."
  default     = false
}


# Create a Node Pool
variable "is_nodepool_created" {
  description = "Boolean variable to specify whether to create node pool or not"
  default     = false
}


# K8 version
variable "control_plane_kubernetes_version" {
  description = "Version of Kubernetes that will be used for the control plane."
}

# Worker nodes version
variable "worker_nodes_kubernetes_version" {
  description = "Version of Kubernetes that will be used for the worker nodes."
}


# K8 networking typ CNI vs FLANNEL
variable "cni_type" {
  description = "CNI type of the OKE cluster."
  default     = "OCI_VCN_IP_NATIVE" # alternatively "FLANNEL_OVERLAY" 
}


# Public Control Plan or not
variable "control_plane_is_public" {
  description = "Assigns a public IP to the control plane."
  default     = false
}


# Image signing or not
variable "image_signing_enabled" {
  description = "Enable image verification for the OKE cluster."
  default     = false
}


# Image Signing Key OCID
variable "image_signing_key_id" {
  type        = list(string)
  description = "The OCID(s) of the keys used to verify the image signature."
  default     = null
}


# Cluster Type
variable "cluster_type" {
  description = "Type of cluster. Supported values include BASIC_CLUSTER and ENHANCED_CLUSTER"
  default     = "ENHANCED_CLUSTER" # alternatively "BASIC_CLUSTER"
}



# Node Pools
variable "node_pools" {
  type        = map(any)
  description = "Node pool configuration."
}

# Create Pod Network Subnet
variable "create_pod_network_subnet" {
  description = "Create PODs Network subnet for OKE. To be used with CNI Type OCI_VCN_IP_NATIVE"
}