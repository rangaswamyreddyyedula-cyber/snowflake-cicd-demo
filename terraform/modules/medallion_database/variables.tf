variable "database_name" {
  description = "Database name."
  type        = string
}

variable "schemas" {
  description = "Schemas (medallion layers) to create."
  type        = list(string)
}

variable "data_retention_days" {
  description = "Time Travel retention in days."
  type        = number
}

variable "comment" {
  description = "Database comment."
  type        = string
}
