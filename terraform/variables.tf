variable "project" {
  description = "Project name, used as the database and role prefix."
  type        = string
  default     = "TEST_CICD_DEMO"
}

variable "environment" {
  description = "Deployment environment: test or prod."
  type        = string

  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "The environment must be test or prod."
  }
}

variable "schemas" {
  description = "Medallion layers, each created as a managed access schema."
  type        = list(string)
  default     = ["BRONZE", "SILVER", "GOLD" ,"SEMANTIC","PUBLISHED"]
}

variable "warehouse_size" {
  description = "Size of the environment warehouse."
  type        = string
  default     = "XSMALL"
}

variable "warehouse_auto_suspend" {
  description = "Seconds of inactivity before the warehouse suspends."
  type        = number
  default     = 60
}

variable "data_retention_days" {
  description = "Time Travel retention for the database, in days."
  type        = number
  default     = 1
}
