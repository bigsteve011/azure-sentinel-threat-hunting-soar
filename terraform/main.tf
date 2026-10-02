resource "azurerm_resource_group" "soc" {
  name     = "rg-security-operations"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "soc" {
  name                = "law-sentinel-soc"
  location            = var.location
  resource_group_name = azurerm_resource_group.soc.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "soc" {
  workspace_id = azurerm_log_analytics_workspace.soc.id
}

locals {
  workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.soc.workspace_id
}

resource "azurerm_sentinel_alert_rule_scheduled" "keyvault_after_risky_signin" {
  name                       = "risky-signin-then-keyvault-secret-access"
  log_analytics_workspace_id = local.workspace_id
  display_name               = "Risky sign-in followed by Key Vault secret access"
  severity                   = "High"
  query                      = file("${path.module}/../queries/risky-signin-then-keyvault-secret-access.kql")
  query_frequency            = "PT15M"
  query_period               = "PT1H"
  tactics                    = ["InitialAccess", "CredentialAccess"]
  techniques                 = ["T1078", "T1555"]

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "FullName"
      column_name = "UserPrincipalName"
    }
  }

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "SigninIP"
    }
  }

  incident {
    create_incident_enabled = true
    grouping {
      enabled                = true
      lookback_duration      = "PT6H"
      entity_matching_method = "AllEntities"
    }
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "impossible_travel" {
  name                       = "impossible-travel"
  log_analytics_workspace_id = local.workspace_id
  display_name               = "Impossible travel between successful sign-ins"
  severity                   = "Medium"
  query                      = file("${path.module}/../queries/impossible-travel.kql")
  query_frequency            = "PT1H"
  query_period               = "P1D"
  tactics                    = ["InitialAccess"]
  techniques                 = ["T1078"]

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "FullName"
      column_name = "UserPrincipalName"
    }
  }

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "IPAddress"
    }
  }
}
