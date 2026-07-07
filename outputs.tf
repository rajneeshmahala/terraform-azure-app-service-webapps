output "web_app_object" {
  description = "The full output object for the created Web App."
  sensitive = true
  value = coalesce(
    try(azurerm_linux_web_app.this["this"], null),
    try(azurerm_windows_web_app.this["this"], null)
  )
}

