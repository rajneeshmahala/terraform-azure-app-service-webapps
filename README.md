## azurerm-res-web-site

### Module Features & Details
- **App Service Deployment**: Deploys either Linux or Windows Web Apps in Azure.
- **VNet Integration**: Configures outbound regional VNet integration (delegated subnet required).
- **Private Endpoints**: Provisions inbound private endpoints for secure access.
- **Private DNS Zones**: Automates DNS group associations to custom private zones.
- **Application Security Groups**: Binds private endpoints to existing ASGs.
- **Managed Identity**: Supports System-Assigned and User-Assigned Managed Identities.
- **App Settings**: Dynamically configures application settings and env variables.
- **Connection Strings**: Sets up database and system connection strings.
- **Diagnostic Settings**: Configures diagnostics to Log Analytics, Event Hubs, or Storage Accounts.
- **Sticky Settings**: Configures slot-sticky app settings and connection strings.
- **Timeouts & Tags**: Supports custom operations timeouts (create, delete, update) and resource tagging.
- **Pre-existing Infrastructure**: Expects VNets, Subnets, and DNS Zones to be created externally and passed as resource IDs.

### Example

```hcl
module "web_app" {
  source = "./azurerm-res-web-site"

  organisation        = "amp"
  environment         = "dev"
  workload            = "app"
  location            = "uksouth"
  name                = "portal"
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"

  service_plan_resource_id = azurerm_service_plan.this.id
  virtual_network_subnet_id = azurerm_subnet.appservice_integration.id

  linux_application_stack = {
    node_version = "20-lts"
  }

  private_endpoints = {
    inbound = {
      subnet_id                     = azurerm_subnet.private_endpoints.id
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.azurewebsites.id]
    }
  }
}
```



❤️contribute by : RajneeshMahala@gmail.com