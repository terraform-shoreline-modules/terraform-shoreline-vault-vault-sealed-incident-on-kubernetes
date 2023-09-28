resource "shoreline_notebook" "vault_sealed_incident" {
  name       = "vault_sealed_incident"
  data       = file("${path.module}/data/vault_sealed_incident.json")
  depends_on = [shoreline_action.invoke_check_vault_config,shoreline_action.invoke_unseal_vault]
}

resource "shoreline_file" "check_vault_config" {
  name             = "check_vault_config"
  input_file       = "${path.module}/data/check_vault_config.sh"
  md5              = filemd5("${path.module}/data/check_vault_config.sh")
  description      = "Issues with the Vault service configuration leading to a failure in the Vault instance."
  destination_path = "/agent/scripts/check_vault_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "unseal_vault" {
  name             = "unseal_vault"
  input_file       = "${path.module}/data/unseal_vault.sh"
  md5              = filemd5("${path.module}/data/unseal_vault.sh")
  description      = "unseal the vault"
  destination_path = "/agent/scripts/unseal_vault.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_vault_config" {
  name        = "invoke_check_vault_config"
  description = "Issues with the Vault service configuration leading to a failure in the Vault instance."
  command     = "`chmod +x /agent/scripts/check_vault_config.sh && /agent/scripts/check_vault_config.sh`"
  params      = ["VAULT_CONTAINER_NAME","VAULT_POD_NAME","NAMESPACE"]
  file_deps   = ["check_vault_config"]
  enabled     = true
  depends_on  = [shoreline_file.check_vault_config]
}

resource "shoreline_action" "invoke_unseal_vault" {
  name        = "invoke_unseal_vault"
  description = "unseal the vault"
  command     = "`chmod +x /agent/scripts/unseal_vault.sh && /agent/scripts/unseal_vault.sh`"
  params      = ["VAULT_NAME","NAMESPACE","POD_NAME"]
  file_deps   = ["unseal_vault"]
  enabled     = true
  depends_on  = [shoreline_file.unseal_vault]
}

