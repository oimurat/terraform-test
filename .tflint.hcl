plugin "terraform" {
    enabled = true
    version = "0.13.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
    preset  = "recommended"
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_naming_convention" {
  enabled = false
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_typed_variables" {
    enabled = false
}