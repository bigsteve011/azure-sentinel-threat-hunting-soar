variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "retention_days" {
  type    = number
  default = 90
}
