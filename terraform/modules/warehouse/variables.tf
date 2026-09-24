variable "name" {
  description = "Warehouse name."
  type        = string
}

variable "size" {
  description = "Warehouse size, e.g. XSMALL."
  type        = string
}

variable "auto_suspend" {
  description = "Seconds of inactivity before suspending."
  type        = number
}

variable "comment" {
  description = "Warehouse comment."
  type        = string
}
