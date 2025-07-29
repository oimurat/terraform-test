# --- 認証情報 ---
variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}
variable "user_ocid" {
  description = "OCI User OCID"
  type        = string
}
variable "fingerprint" {
  description = "API Key Fingerprint"
  type        = string
}
variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}
variable "region" {
  description = "OCI Region"
  default     = "ap-tokyo-1" # 東京リージョン
}
variable "compartment_ocid" {
  description = "Compartment OCID to deploy resources"
  type        = string
}

# --- ネットワーク構成 ---
variable "vcn_cidr" {
  description = "CIDR for the VCN"
  default     = "10.0.0.0/16"
}
variable "api_subnet_cidr" {
  description = "CIDR for the K8s API Endpoint Subnet"
  default     = "10.0.0.0/28"
}
variable "node_subnet_cidr" {
  description = "CIDR for the Node Pool Subnet"
  default     = "10.0.10.0/24"
}
variable "lb_subnet_cidr" {
  description = "CIDR for the Load Balancer Subnet"
  default     = "10.0.20.0/24"
}

# --- OKEクラスタ構成 ---
variable "k8s_version" {
  description = "Kubernetes version for the cluster"
  default     = "v1.33.1" # 注意: OCIで利用可能な最新版を確認して指定してください。
}

# --- ノードプール構成 ---
variable "node_pool_name" {
  description = "Name of the node pool"
  default     = "pool1"
}
variable "node_count" {
  description = "Number of nodes in the node pool"
  default     = 4
}
variable "node_shape" {
  description = "Shape for the worker nodes"
  default     = "VM.Standard.E4.Flex"
}
variable "node_ocpus" {
  description = "OCPU count for each worker node"
  default     = 1
}
variable "node_memory_in_gbs" {
  description = "Memory in GBs for each worker node"
  default     = 8
}

# --- OKEクラスタ & ノードプール構成 --- のセクションに以下を追加

variable "node_os" {
  description = "Operating system for the worker nodes"
  default     = "Oracle-Linux"
}

variable "node_os_version" {
  description = "Major version of the operating system"
  default     = "9" # OL9を指定
}

variable "node_shape_to_arch" {
  description = "A map to determine architecture from shape name."
  type        = map(string)
  default = {
    "VM.Standard.E4.Flex" = "x86_64"
    "VM.Standard.A1.Flex" = "aarch64"
    "VM.Optimized3.Flex"  = "x86_64"
    "BM.Standard.E4.128"  = "x86_64"
    "BM.GPU.A10.4"        = "x86_64"
  }
}