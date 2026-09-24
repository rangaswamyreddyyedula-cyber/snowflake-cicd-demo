variable "name" {
  description = "Account role name."
  type        = string
}

variable "comment" {
  description = "Account role comment."
  type        = string
}

variable "database_roles" {
  description = "Fully qualified database roles to grant, keyed by a static label."
  type        = map(string)
}

variable "warehouse_name" {
  description = "Warehouse the role may use."
  type        = string
}

variable "parent_role" {
  description = "Parent account role in the hierarchy."
  type        = string
}
