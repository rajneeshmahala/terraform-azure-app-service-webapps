## azurerm-res-web-site

Terraform module for deploying an Azure Web App with optional regional VNet integration, private endpoints, private DNS zone group association, diagnostics, managed identity, app settings, connection strings, and common site configuration.

### Networking

This module does not create VNets, subnets, route tables, NSGs, firewalls, private DNS zones, or private DNS zone VNet links. Those are expected to be created by network modules and passed in as IDs.

- `virtual_network_subnet_id` configures outbound regional VNet integration for the Web App. The subnet should be delegated to `Microsoft.Web/serverFarms`.
- `private_endpoints` creates inbound private endpoints for the Web App. For the default `sites` subresource, use the private DNS zone `privatelink.azurewebsites.net`.
- `private_dns_zone_resource_ids` attaches existing private DNS zones to the private endpoint through a private DNS zone group.
- `application_security_group_associations` associates the private endpoint NIC with existing ASGs.

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