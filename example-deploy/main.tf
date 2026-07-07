provider "azurerm" {
  features {}
}

# Create a resource group for the example resources
resource "azurerm_resource_group" "example" {
  name     = "rg-webapp-example-deploy"
  location = "Central India"
}

# Create an App Service Plan
resource "azurerm_service_plan" "example" {
  name                = "asp-webapp-example-deploy"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "F1" # Free tier
}

# Invoke the local Web App module
module "web_app" {
  source = "../"

  organisation             = "ot"
  environment              = "dev"
  workload                 = "test"
  location                 = azurerm_resource_group.example.location
  name                     = "examplewebapp"
  resource_group_name      = azurerm_resource_group.example.name
  os_type                  = "Linux"
  service_plan_resource_id = azurerm_service_plan.example.id

  site_config = {
    always_on         = false
    use_32_bit_worker = true
  }
}
