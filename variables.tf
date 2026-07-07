variable "organisation" {
  type        = string
  description = "Required. The organisation deploying resources."
}

variable "environment" {
  type        = string
  description = "Required. The environment where this resource is deployed."
}

variable "workload" {
  type        = string
  description = "Required. The workload for this resource."
}

variable "location" {
  type        = string
  description = "Required. Azure region where the Web App should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "Required. The base name for the Web App."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "Required. The resource group where the Web App will be deployed."
  nullable    = false
}

variable "os_type" {
  type        = string
  description = "Required. The Web App operating system. Valid values are Linux and Windows."
  nullable    = false

  validation {
    condition     = contains(["linux", "windows"], lower(var.os_type))
    error_message = "The os_type value must be either Linux or Windows."
  }
}

variable "service_plan_resource_id" {
  type        = string
  description = "Required. The resource ID of the App Service Plan."
  nullable    = false
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "A map of app settings for the Web App."
}

variable "client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Should client affinity be enabled?"
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Should client certificates be enabled?"
}

variable "client_certificate_exclusion_paths" {
  type        = string
  default     = null
  description = "Paths to exclude when using client certificates, separated by semicolons."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "The client certificate mode."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Should the Web App be enabled?"
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should FTP basic authentication publishing be enabled?"
}

variable "https_only" {
  type        = bool
  default     = true
  description = "Should the Web App require HTTPS?"
}

variable "key_vault_reference_identity_id" {
  type        = string
  default     = null
  description = "The user assigned identity ID used for Key Vault references."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Should public network access be enabled for the Web App?"
}

variable "virtual_network_backup_restore_enabled" {
  type        = bool
  default     = false
  description = "Whether backup and restore operations over the linked virtual network are enabled."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID used for regional VNet integration. The subnet should be delegated to Microsoft.Web/serverFarms."
}

variable "vnet_image_pull_enabled" {
  type        = bool
  default     = false
  description = "Should container image pull traffic be routed over VNet integration?"
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Should WebDeploy basic authentication publishing be enabled?"
}

variable "zip_deploy_file" {
  type        = string
  default     = null
  description = "The local path and filename of the Zip packaged application to deploy."
}

variable "site_config" {
  type = object({
    always_on                                     = optional(bool, true)
    api_definition_url                            = optional(string)
    api_management_api_id                         = optional(string)
    app_command_line                              = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))
    ftps_state                                    = optional(string, "FtpsOnly")
    health_check_eviction_time_in_min             = optional(number)
    health_check_path                             = optional(string)
    http2_enabled                                 = optional(bool, true)
    ip_restriction_default_action                 = optional(string, "Allow")
    load_balancing_mode                           = optional(string, "LeastRequests")
    managed_pipeline_mode                         = optional(string, "Integrated")
    minimum_tls_version                           = optional(string, "1.2")
    remote_debugging_enabled                      = optional(bool, false)
    remote_debugging_version                      = optional(string)
    scm_ip_restriction_default_action             = optional(string, "Allow")
    scm_minimum_tls_version                       = optional(string, "1.2")
    scm_use_main_ip_restriction                   = optional(bool, false)
    use_32_bit_worker                             = optional(bool, false)
    vnet_route_all_enabled                        = optional(bool, false)
    websockets_enabled                            = optional(bool, false)
    worker_count                                  = optional(number)
    cors = optional(map(object({
      allowed_origins     = set(string)
      support_credentials = optional(bool, false)
    })), {})
    ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {})
    scm_ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {})
  })
  default     = {}
  description = "Site configuration for the Web App."
}

variable "linux_application_stack" {
  type = object({
    docker_image_name        = optional(string)
    docker_registry_password = optional(string)
    docker_registry_url      = optional(string)
    docker_registry_username = optional(string)
    dotnet_version           = optional(string)
    go_version               = optional(string)
    java_server              = optional(string)
    java_server_version      = optional(string)
    java_version             = optional(string)
    node_version             = optional(string)
    php_version              = optional(string)
    python_version           = optional(string)
    ruby_version             = optional(string)
  })
  default     = null
  description = "Linux Web App application stack configuration."
  sensitive   = true
}

variable "windows_application_stack" {
  type = object({
    current_stack                = optional(string)
    docker_image_name            = optional(string)
    docker_registry_password     = optional(string)
    docker_registry_url          = optional(string)
    docker_registry_username     = optional(string)
    dotnet_core_version          = optional(string)
    dotnet_version               = optional(string)
    java_container               = optional(string)
    java_container_version       = optional(string)
    java_embedded_server_enabled = optional(bool)
    java_version                 = optional(string)
    node_version                 = optional(string)
    php_version                  = optional(string)
    python                       = optional(bool)
    tomcat_version               = optional(string)
  })
  default     = null
  description = "Windows Web App application stack configuration."
  sensitive   = true
}

variable "connection_strings" {
  type = map(object({
    name  = string
    type  = string
    value = string
  }))
  default     = {}
  description = "Connection strings to configure on the Web App."
  sensitive   = true
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identity configuration for the Web App."
  nullable    = false
}

variable "sticky_settings" {
  type = object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
  })
  default     = null
  description = "Sticky app setting and connection string names."
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = "A map of diagnostic settings to create on the Web App."
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)
    ])
    error_message = "Log analytics destination type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
    ])
    error_message = "At least one diagnostic destination must be provided."
  }
}

variable "private_endpoints" {
  type = map(object({
    name                                    = optional(string, null)
    subnet_id                               = string
    subresource_names                       = optional(list(string), ["sites"])
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
      member_name        = optional(string, "sites")
      subresource_name   = optional(string, "sites")
    })), {})
    tags = optional(map(string), null)
  }))
  default     = {}
  description = "Private endpoint configuration for inbound private access to the Web App. Use private DNS zone privatelink.azurewebsites.net for the default sites subresource."
  nullable    = false
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether this module should create private_dns_zone_group blocks on private endpoints when private_dns_zone_resource_ids are supplied."
  nullable    = false
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = "Timeouts for the Web App resource."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Custom tags to apply to the Web App."
}
