locals {
  schemas = toset(var.schemas)
}

resource "snowflake_database" "this" {
  name                        = var.database_name
  comment                     = var.comment
  data_retention_time_in_days = var.data_retention_days
}

# Managed access: only the schema owner (Terraform) or MANAGE GRANTS can grant.
# Object creators cannot share their tables on their own.
resource "snowflake_schema" "this" {
  for_each = local.schemas

  database            = snowflake_database.this.name
  name                = each.value
  with_managed_access = true
  comment             = "${each.value} layer - managed access schema, managed by Terraform"
}

# ---------------------------------------------------------------------------
# Access roles: one read-only (RO) and one read/write (RW) database role per layer
# ---------------------------------------------------------------------------
resource "snowflake_database_role" "ro" {
  for_each = local.schemas

  database = snowflake_database.this.name
  name     = "${each.value}_RO"
  comment  = "Read-only access to ${each.value}"
}

resource "snowflake_database_role" "rw" {
  for_each = local.schemas

  database = snowflake_database.this.name
  name     = "${each.value}_RW"
  comment  = "Read/write access to ${each.value}"
}

# RW inherits everything RO has
resource "snowflake_grant_database_role" "ro_to_rw" {
  for_each = local.schemas

  database_role_name        = snowflake_database_role.ro[each.key].fully_qualified_name
  parent_database_role_name = snowflake_database_role.rw[each.key].fully_qualified_name
}

# ---- RO privileges ----
resource "snowflake_grant_privileges_to_database_role" "ro_database_usage" {
  for_each = local.schemas

  database_role_name = snowflake_database_role.ro[each.key].fully_qualified_name
  privileges         = ["USAGE"]
  on_database        = snowflake_database.this.name
}

resource "snowflake_grant_privileges_to_database_role" "ro_schema_usage" {
  for_each = local.schemas

  database_role_name = snowflake_database_role.ro[each.key].fully_qualified_name
  privileges         = ["USAGE"]

  on_schema {
    schema_name = snowflake_schema.this[each.key].fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_database_role" "ro_future_tables" {
  for_each = local.schemas

  database_role_name = snowflake_database_role.ro[each.key].fully_qualified_name
  privileges         = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this[each.key].fully_qualified_name
    }
  }
}

resource "snowflake_grant_privileges_to_database_role" "ro_future_views" {
  for_each = local.schemas

  database_role_name = snowflake_database_role.ro[each.key].fully_qualified_name
  privileges         = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.this[each.key].fully_qualified_name
    }
  }
}

# ---- RW privileges (on top of RO) ----
resource "snowflake_grant_privileges_to_database_role" "rw_schema_create" {
  for_each = local.schemas

  database_role_name = snowflake_database_role.rw[each.key].fully_qualified_name

  privileges = [
    "CREATE TABLE",
    "CREATE VIEW",
    "CREATE STAGE",
    "CREATE FILE FORMAT",
    "CREATE SEQUENCE",
    "CREATE FUNCTION",
    "CREATE PROCEDURE",
    "CREATE STREAM",
    "CREATE TASK",
  ]

  on_schema {
    schema_name = snowflake_schema.this[each.key].fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_database_role" "rw_future_tables" {
  for_each = local.schemas

  database_role_name = snowflake_database_role.rw[each.key].fully_qualified_name
  privileges         = ["INSERT", "UPDATE", "DELETE", "TRUNCATE"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this[each.key].fully_qualified_name
    }
  }
}
