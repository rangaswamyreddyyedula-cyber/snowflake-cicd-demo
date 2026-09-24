output "database_name" {
  description = "Database created for this environment."
  value       = module.demo_database.database_name
}

output "schemas" {
  description = "Fully qualified schema names."
  value       = module.demo_database.schema_names
}

output "warehouse_name" {
  description = "Warehouse created for this environment."
  value       = module.warehouse.name
}

output "account_roles" {
  description = "Functional roles created for this environment."
  value       = [module.engineer_role.name, module.analyst_role.name]
}
