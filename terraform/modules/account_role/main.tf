resource "snowflake_account_role" "this" {
  name    = var.name
  comment = var.comment
}

# Functional role receives the schema access roles
resource "snowflake_grant_database_role" "this" {
  for_each = var.database_roles

  database_role_name = each.value
  parent_role_name   = snowflake_account_role.this.name
}

resource "snowflake_grant_privileges_to_account_role" "warehouse_usage" {
  account_role_name = snowflake_account_role.this.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

# Keep the role hierarchy connected (role -> SYSADMIN)
resource "snowflake_grant_account_role" "to_parent" {
  role_name        = snowflake_account_role.this.name
  parent_role_name = var.parent_role
}
