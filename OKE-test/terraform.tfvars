# OCI認証情報
# これらの変数は通常、プロバイダブロック (provider "oci" {}) で直接参照されます。
# プロバイダブロックがこれらの変数を参照するように設定されていることを確認してください。
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaawwkc6q2pxhc3qyb56y4crpktzae4o2govvkrmwqkryll2yourjsa"
user_ocid        = "ocid1.user.oc1..aaaaaaaawzy3h42dfff3fyhdwq46lckqfuyba2tdwrkhkbc7ljll3etahwnq"
fingerprint      = "5e:e1:00:f9:c2:d5:09:c8:a1:86:cf:f7:1d:11:0d:b1"
private_key_path = "C:/Users/odaj/ssh-rsa_20250715_private.pem" # Windowsパスはスラッシュ '/' を使用

# クラスターがデプロイされるコンパートメントOCID
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaanqvbyh2fedz2w7r2v7jc42idrbe55menyixwic64igzeqxf36vaa"

# --- ネットワーク関連のパラメータ ---
# VCNのCIDRブロック
vcn_cidr = "10.0.0.0/16"

# サブネットのCIDRブロック (VCNの範囲内で重複しないように設定)
api_subnet_cidr  = "10.0.1.0/24" # OKE APIエンドポイント用
lb_subnet_cidr   = "10.0.2.0/24" # ロードバランサー用
node_subnet_cidr = "10.0.3.0/24" # OKE ノードプール用

# --- OKE クラスターおよびノードプール関連のパラメータ ---
# Kubernetes のバージョン
# OCIのサポートバージョンに合わせてください。例: "v1.28.x"
# k8s.oraclecloud.com で最新情報を確認できます
k8s_version = "v1.33.1"

# ノードシェイプの指定 (利用可能なシェイプに合わせてください)
node_shape = "VM.Standard.E4.Flex"

# ノードのOCPU数 (node_shapeがサポートする値にしてください)
node_ocpus = 2

# ノードのメモリ量 (GB) (node_ocpusと合わせて、node_shapeがサポートする値にしてください)
node_memory_in_gbs = 16

# ノードの数 (最小1から。必要に応じて増やしてください)
node_count = 1

# (オプション) OKEノードへのSSH接続用の公開鍵のパス
# resource "oci_containerengine_node_pool" で `ssh_public_key` を設定する場合に必要です。
# ssh_public_key_path = "C:/Users/odaj/.ssh/id_rsa.pub" # 使用する場合、コメントアウトを解除し、正しいパスを指定