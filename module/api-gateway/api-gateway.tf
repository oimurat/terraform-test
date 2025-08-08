# API Gatewayを作成
resource "oci_apigateway_gateway" "api_gateway" {
  #Required
  compartment_id = var.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = var.subnet_ocid

  #Optional
  display_name = "${var.env}-api-gateway"
}

# デプロイメントを作成
resource "oci_apigateway_deployment" "deployment" {
  #Required
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.api_gateway.id
  path_prefix    = "/"
  specification {

    #Optional
    # request_policies {

    #     #Optional
    #     authentication {
    #         #Required
    #         type = "JWT_AUTHENTICATION"

    #         #Optional
    #         audiences = var.deployment_specification_request_policies_authentication_audiences #トークンの対象受信者のリスト(type=JWT_AUTHENTICATION の場合は必須)
    #         is_anonymous_access_allowed = var.deployment_specification_request_policies_authentication_is_anonymous_access_allowed #認証されていないユーザーがAPIにアクセスできるかどうか
    #         issuers = var.deployment_specification_request_policies_authentication_issuers #トークンを発行した可能性のある当事者のリスト(type=JWT_AUTHENTICATION の場合は必須)
    #         max_clock_skew_in_seconds = var.deployment_specification_request_policies_authentication_max_clock_skew_in_seconds #トークン発行者のシステム クロックと API ゲートウェイ間の最大予想時間差(type=JWT_AUTHENTICATIONの場合に適用可能)
    #         # JWT 署名の検証に使用される公開鍵のセット(type=JWT_AUTHENTICATION の場合は必須)
    #         public_keys {
    #             #Required
    #             type = var.deployment_specification_request_policies_authentication_public_keys_type #公開鍵セットの種類(REMOTE_JWKS,STATIC_KEYS)

    #             #Optional
    #             is_ssl_verify_disabled = var.deployment_specification_request_policies_authentication_public_keys_is_ssl_verify_disabled #SSL 検証を維持するかどうかを定義(type=REMOTE_JWKS の場合に適用可能)
    #             # 静的公開鍵のセット(type=STATIC_KEYS の場合に適用可能)
    #             keys {
    #                 #Required
    #                 format = var.deployment_specification_request_policies_authentication_public_keys_keys_format #公開キーの形式(JSON_WEB_KEY,PEM)

    #                 #Optional
    #                 alg = var.deployment_specification_request_policies_authentication_public_keys_keys_alg #このキーで使用するためのアルゴリズム(format=JSON_WEB_KEY の場合は必須)
    #                 e = var.deployment_specification_request_policies_authentication_public_keys_keys_e #このキーによって表される RSA 公開キーの base64 URL エンコードされた指数(format=JSON_WEB_KEY の場合は必須)
    #                 key = var.deployment_specification_request_policies_authentication_public_keys_keys_key #PEM でエンコードされた公開キーの内容(format=PEM の場合は必須)
    #                 key_ops = var.deployment_specification_request_policies_authentication_public_keys_keys_key_ops #このキーが使用される操作(format=JSON_WEB_KEY の場合に適用可能)
    #                 kid = var.deployment_specification_request_policies_authentication_public_keys_keys_kid #一意のキーID(type=STATIC_KEYSの場合必須)
    #                 kty = var.deployment_specification_request_policies_authentication_public_keys_keys_kty #キーの種類(format=JSON_WEB_KEY の場合は必須)
    #                 n = var.deployment_specification_request_policies_authentication_public_keys_keys_n #このキーによって表される RSA 公開キーの base64 URL エンコードされた係数(format=JSON_WEB_KEY の場合は必須)
    #                 use = var.deployment_specification_request_policies_authentication_public_keys_keys_use #公開鍵の使用目的(format=JSON_WEB_KEY の場合に適用可能)
    #             }
    #             max_cache_duration_in_hours = var.deployment_specification_request_policies_authentication_public_keys_max_cache_duration_in_hours #JWKS が再度取得されるまでにキャッシュされる期間(type=REMOTE_JWKS の場合に適用可能)
    #             uri = var.deployment_specification_request_policies_authentication_public_keys_uri #認証なしでアクセスできるキーを取得するURI(type=REMOTE_JWKS の場合に必須)
    #         }
    #         token_auth_scheme = var.deployment_specification_request_policies_authentication_token_auth_scheme #トークンの認証時に使用する認証スキーム(type=JWT_AUTHENTICATIONの場合に適用)
    #         token_header = var.deployment_specification_request_policies_authentication_token_header #認証トークンを含むヘッダーの名前
    #         token_query_param = var.deployment_specification_request_policies_authentication_token_query_param #認証トークンを含むクエリ パラメータの名前
    #         #トークンを有効と見なすために検証する必要があるクレームのリスト(type=JWT_AUTHENTICATION の場合に適用可能)
    #         verify_claims {

    #             #Optional
    #             is_required = var.deployment_specification_request_policies_authentication_verify_claims_is_required #JWT にクレームが存在する必要があるかどうか(type=JWT_AUTHENTICATION の場合に適用)
    #             key = var.deployment_specification_request_policies_authentication_verify_claims_key #クレームの名前(type=JWT_AUTHENTICATION の場合は必須)
    #             values = var.deployment_specification_request_policies_authentication_verify_claims_values #特定のクレームに許容される値のリスト(type=JWT_AUTHENTICATION の場合に適用)
    #         }
    #     }
    # }
    routes {
      #Required
      backend {
        #Required
        type = "HTTP_BACKEND"
        url  = "https://graphql.dev.ec-gaihan-development.com/graphql"

        #Optional
        is_ssl_verify_disabled = true
      }
      methods = ["POST"]
      path    = "/graphql"
    }
  }

  #Optional
  display_name = "${var.env}-deployment"
}
