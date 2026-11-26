output "app_identity_id" {
  description = "App identity used for PostgreSQL permissions"
  value = try(
    azurerm_linux_web_app.backend[0].identity[0].principal_id,
    null
  )
}
