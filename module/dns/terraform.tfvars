# OCI認証情報
tenancy_ocid     = ""
user_ocid        = ""
fingerprint      = ""
private_key_path = ""
region           = "ap-tokyo-1"

# リソース配置情報
compartment_id = ""

vcn_id         = ""
# --- LB用の設定を追加 ---
# ↓ ここにLBのOCIDを記述します
lb_ocid = "" # ← コピーしたLBのOCID

# terraform.tfvars

# ↓ この行を追記します
endpoint_subnet_id = ""

# terraform.tfvars

# ↓ この変数を追記します
# forwarding_rules = {}

# terraform.tfvars

# ↓ この変数を追記します
forwarding_rules = {
  "onprem_rule" = {
    domains               = ["graphql.dev.ec-gaihan-development.com"]
    destination_addresses = ["10.0.1.8"]
    # client_address_conditions = ["192.168.0.0/16"] # オプション: 特定のCIDRからの問い合わせのみを対象にする場合
  }
}