output "database_name" {
  description = "Database name."
  value       = snowflake_database.this.name
}

output "schema_names" {
  description = "Fully qualified schema names."
  value       = [for s in snowflake_schema.this : s.fully_qualified_name]
}

output "ro_database_roles" {
  description = "Read-only database roles, keyed by schema."
  value       = { for k, r in snowflake_database_role.ro : k => r.fully_qualified_name }
}

output "rw_database_roles" {
  description = "Read/write database roles, keyed by schema."
  value       = { for k, r in snowflake_database_role.rw : k => r.fully_qualified_name }
}
