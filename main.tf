resource "random_integer" "suffix" {
  min = 100
  max = 999
}

locals {
  web_app_name = lower("app-${var.organisation}-${var.environment}-${var.workload}-${var.location}-${var.name}-${random_integer.suffix.result}")

  web_app_id = coalesce(
    try(azurerm_linux_web_app.this["this"].id, null),
    try(azurerm_windows_web_app.this["this"].id, null)
  )

  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
}

resource "azurerm_linux_web_app" "this" {
  for_each = lower(var.os_type) == "linux" ? { this = true } : {}

  name                                           = local.web_app_name
  location                                       = var.location
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = var.service_plan_resource_id
  app_settings                                   = var.app_settings
  client_affinity_enabled                        = var.client_affinity_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  client_certificate_mode                        = var.client_certificate_mode
  enabled                                        = var.enabled
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  https_only                                     = var.https_only
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  public_network_access_enabled                  = var.public_network_access_enabled
  tags                                           = var.tags
  virtual_network_backup_restore_enabled         = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  vnet_image_pull_enabled                        = var.vnet_image_pull_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file

  site_config {
    always_on                                     = var.site_config.always_on
    api_definition_url                            = var.site_config.api_definition_url
    api_management_api_id                         = var.site_config.api_management_api_id
    app_command_line                              = var.site_config.app_command_line
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    default_documents                             = var.site_config.default_documents
    ftps_state                                    = var.site_config.ftps_state
    health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
    health_check_path                             = var.site_config.health_check_path
    http2_enabled                                 = var.site_config.http2_enabled
    ip_restriction_default_action                 = var.site_config.ip_restriction_default_action
    load_balancing_mode                           = var.site_config.load_balancing_mode
    managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
    minimum_tls_version                           = var.site_config.minimum_tls_version
    remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
    remote_debugging_version                      = var.site_config.remote_debugging_version
    scm_ip_restriction_default_action             = var.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                             = var.site_config.use_32_bit_worker
    vnet_route_all_enabled                        = var.site_config.vnet_route_all_enabled
    websockets_enabled                            = var.site_config.websockets_enabled
    worker_count                                  = var.site_config.worker_count

    dynamic "application_stack" {
      for_each = nonsensitive(var.linux_application_stack == null ? [] : [var.linux_application_stack])

      content {
        docker_image_name        = application_stack.value.docker_image_name
        docker_registry_password = application_stack.value.docker_registry_password
        docker_registry_url      = application_stack.value.docker_registry_url
        docker_registry_username = application_stack.value.docker_registry_username
        dotnet_version           = application_stack.value.dotnet_version
        go_version               = application_stack.value.go_version
        java_server              = application_stack.value.java_server
        java_server_version      = application_stack.value.java_server_version
        java_version             = application_stack.value.java_version
        node_version             = application_stack.value.node_version
        php_version              = application_stack.value.php_version
        python_version           = application_stack.value.python_version
        ruby_version             = application_stack.value.ruby_version
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restriction

      content {
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id

        dynamic "headers" {
          for_each = ip_restriction.value.headers

          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.site_config.scm_ip_restriction

      content {
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers

          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "identity" {
    for_each = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? { this = var.managed_identities } : {}

    content {
      type         = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(identity.value.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = var.sticky_settings == null ? [] : [var.sticky_settings]

    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      connection_string,
      site_config[0].application_stack[0].docker_image_name
    ]
  }
}

resource "azurerm_windows_web_app" "this" {
  for_each = lower(var.os_type) == "windows" ? { this = true } : {}

  name                                           = local.web_app_name
  location                                       = var.location
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = var.service_plan_resource_id
  app_settings                                   = var.app_settings
  client_affinity_enabled                        = var.client_affinity_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  client_certificate_mode                        = var.client_certificate_mode
  enabled                                        = var.enabled
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  https_only                                     = var.https_only
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  public_network_access_enabled                  = var.public_network_access_enabled
  tags                                           = var.tags
  virtual_network_backup_restore_enabled         = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file

  site_config {
    always_on                         = var.site_config.always_on
    api_definition_url                = var.site_config.api_definition_url
    api_management_api_id             = var.site_config.api_management_api_id
    app_command_line                  = var.site_config.app_command_line
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    default_documents                 = var.site_config.default_documents
    ftps_state                        = var.site_config.ftps_state
    health_check_eviction_time_in_min = var.site_config.health_check_eviction_time_in_min
    health_check_path                 = var.site_config.health_check_path
    http2_enabled                     = var.site_config.http2_enabled
    ip_restriction_default_action     = var.site_config.ip_restriction_default_action
    load_balancing_mode               = var.site_config.load_balancing_mode
    managed_pipeline_mode             = var.site_config.managed_pipeline_mode
    minimum_tls_version               = var.site_config.minimum_tls_version
    remote_debugging_enabled          = var.site_config.remote_debugging_enabled
    remote_debugging_version          = var.site_config.remote_debugging_version
    scm_ip_restriction_default_action = var.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version           = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction       = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                 = var.site_config.use_32_bit_worker
    vnet_route_all_enabled            = var.site_config.vnet_route_all_enabled
    websockets_enabled                = var.site_config.websockets_enabled
    worker_count                      = var.site_config.worker_count

    dynamic "application_stack" {
      for_each = nonsensitive(var.windows_application_stack == null ? [] : [var.windows_application_stack])

      content {
        current_stack                = application_stack.value.current_stack
        docker_image_name            = application_stack.value.docker_image_name
        docker_registry_password     = application_stack.value.docker_registry_password
        docker_registry_url          = application_stack.value.docker_registry_url
        docker_registry_username     = application_stack.value.docker_registry_username
        dotnet_core_version          = application_stack.value.dotnet_core_version
        dotnet_version               = application_stack.value.dotnet_version
        java_container               = application_stack.value.java_container
        java_container_version       = application_stack.value.java_container_version
        java_embedded_server_enabled = application_stack.value.java_embedded_server_enabled
        java_version                 = application_stack.value.java_version
        node_version                 = application_stack.value.node_version
        php_version                  = application_stack.value.php_version
        python                       = application_stack.value.python
        tomcat_version               = application_stack.value.tomcat_version
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restriction

      content {
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.site_config.scm_ip_restriction

      content {
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "identity" {
    for_each = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? { this = var.managed_identities } : {}

    content {
      type         = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(identity.value.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = var.sticky_settings == null ? [] : [var.sticky_settings]

    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      connection_string,
      site_config[0].application_stack[0].docker_image_name
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${local.web_app_name}"
  target_resource_id             = local.web_app_id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories

    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  location                      = each.value.location != null ? each.value.location : var.location
  name                          = each.value.name != null ? each.value.name : "pe-${local.web_app_name}"
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${local.web_app_name}"
    private_connection_resource_id = local.web_app_id
    subresource_names              = each.value.subresource_names
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = (var.private_endpoints_manage_dns_zone_group && length(each.value.private_dns_zone_resource_ids) > 0) ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = local.private_endpoint_application_security_group_associations

  application_security_group_id = each.value.asg_resource_id
  private_endpoint_id           = azurerm_private_endpoint.this[each.value.pe_key].id
}
