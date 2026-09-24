locals {
  env_upper = upper(var.environment)
  prefix    = "${upper(var.project)}_${local.env_upper}" # e.g. TEST_CICD_DEMO_TEST
}

# Compute for this environment
module "warehouse" {
  source = "./modules/warehouse"

  name         = "${local.prefix}_WH"
  size         = var.warehouse_size
  auto_suspend = var.warehouse_auto_suspend
  comment      = "Compute for ${local.prefix} - managed by Terraform"
}

# Database with BRONZE / SILVER / GOLD managed access schemas and access roles
module "demo_database" {
  source = "./modules/medallion_database"

  database_name       = local.prefix
  schemas             = var.schemas
  data_retention_days = var.data_retention_days
  comment             = "CI/CD demo database (${var.environment}) - managed by Terraform"
}

# Functional role: engineers read/write every layer
module "engineer_role" {
  source = "./modules/account_role"

  name           = "${local.prefix}_ENGINEER"
  comment        = "Read/write on all medallion layers in ${local.prefix}"
  database_roles = module.demo_database.rw_database_roles
  warehouse_name = module.warehouse.name
  parent_role    = "SYSADMIN"
}

# Functional role: analysts read GOLD only
module "analyst_role" {
  source = "./modules/account_role"

  name           = "${local.prefix}_ANALYST"
  comment        = "Read-only on the GOLD layer in ${local.prefix}"
  database_roles = { GOLD = module.demo_database.ro_database_roles["GOLD"] }
  warehouse_name = module.warehouse.name
  parent_role    = "SYSADMIN"
}
