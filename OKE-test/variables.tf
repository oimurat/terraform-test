variable "tenancy_ocid" {
  description = "Your OCI Tenancy OCID"
  type        = string
}

variable "user_ocid" {
  description = "Your OCI User OCID"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the API Key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

variable "region" {
  description = "OCI Region where resources will be deployed"
  type        = string
  default     = "ap-tokyo-1" # 東京リージョン
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "k8s_api_subnet_cidr" {
  description = "CIDR block for the Kubernetes API endpoint subnet"
  type        = string
  default     = "10.0.0.0/28" # ご希望の 10.0.0.0/28 に設定。ただし tfvars で上書きされる
}

variable "node_subnet_cidr" {
  description = "CIDR block for the worker node subnet"
  type        = string
  default     = "10.0.10.0/24" # ご希望の 10.0.10.0/24 に設定。ただし tfvars で上書きされる
}

variable "lb_subnet_cidr" {
  description = "CIDR block for the Load Balancer subnet"
  type        = string
  default     = "10.0.20.0/24" # ご希望の 10.0.20.0/24 に設定。ただし tfvars で上書きされる
}

variable "oke_cluster_name" {
  description = "Name for the OKE cluster"
  type        = string
  default     = "my-oke-cluster"
}

variable "node_count" {
  description = "Number of worker nodes in the node pool"
  type        = number
  default     = 4
}

variable "node_shape" {
  description = "Shape for the worker nodes"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  description = "Number of OCPUs for the worker nodes"
  type        = number
  default     = 1
}

variable "node_memory_in_gbs" {
  description = "Memory in GBs for the worker nodes"
  type        = number
  default     = 8
}

variable "node_os_image_name" {
  description = "Operating System image name for worker nodes"
  type        = string
  default     = "OracleLinux 9" # OCIが提供するイメージ名に合わせてください
}

variable "oke_kubernetes_version" {
  description = "Kubernetes version for the OKE cluster"
  type        = string
  default     = "v1.33.1" # 指定されたバージョン
}

# ノードプールへのSSH接続用の公開鍵のパスをもし変数として定義するなら
# (メインのtfファイルで ssh_public_key を直接指定する場合や、ユーザーデータで渡す場合は不要)
# variable "ssh_public_key_path" {
#   description = "Path to the public SSH key file for OKE nodes (if used)"
#   type        = string
#   default     = "" # 必要に応じてパスを指定
# }