resource "shoreline_notebook" "vault_sealed_incident" {
  name       = "vault_sealed_incident"
  data       = file("${path.module}/data/vault_sealed_incident.json")
  depends_on = [shoreline_action.invoke_vault_status_check,shoreline_action.invoke_vault_unseal]
}

resource "shoreline_file" "vault_status_check" {
  name             = "vault_status_check"
  input_file       = "${path.module}/data/vault_status_check.sh"
  md5              = filemd5("${path.module}/data/vault_status_check.sh")
  description      = "Issues with the Vault service configuration leading to a failure in the Vault instance."
  destination_path = "/agent/scripts/vault_status_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "vault_unseal" {
  name             = "vault_unseal"
  input_file       = "${path.module}/data/vault_unseal.sh"
  md5              = filemd5("${path.module}/data/vault_unseal.sh")
  description      = "unseal the vault"
  destination_path = "/agent/scripts/vault_unseal.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_vault_status_check" {
  name        = "invoke_vault_status_check"
  description = "Issues with the Vault service configuration leading to a failure in the Vault instance."
  command     = "`chmod +x /agent/scripts/vault_status_check.sh && /agent/scripts/vault_status_check.sh`"
  params      = ["VAULT_POD_NAME","VAULT_CONTAINER_NAME","NAMESPACE"]
  file_deps   = ["vault_status_check"]
  enabled     = true
  depends_on  = [shoreline_file.vault_status_check]
}

resource "shoreline_action" "invoke_vault_unseal" {
  name        = "invoke_vault_unseal"
  description = "unseal the vault"
  command     = "`chmod +x /agent/scripts/vault_unseal.sh && /agent/scripts/vault_unseal.sh`"
  params      = ["POD_NAME","VAULT_NAME","NAMESPACE"]
  file_deps   = ["vault_unseal"]
  enabled     = true
  depends_on  = [shoreline_file.vault_unseal]
}

