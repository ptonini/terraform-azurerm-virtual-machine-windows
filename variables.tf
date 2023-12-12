variable "name" {}

variable "rg" {
  type = object({
    name      = string
    locations = string
  })
}

variable "host_count" {
  default = 1
}

variable "high_availability" {
  default = false
}


# Network settings ####################

variable "subnet_id" {}

variable "public_ip" {
  default = false
}

variable "network_rules" {
  default = {}
}


# VM settings #########################

variable "admin_username" {
  default = "cloud-user"
}

variable "admin_password" {}

variable "size" {
  default = "Standard_B1s"
}

variable "source_image_id" {
  default = null
}

variable "os_disk_size_gb" {
  default = 30
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

variable "boot_diagnostics_storage_account" {}

variable "sku_tier" {
  default = "Standard"
}

variable "identity_type" {
  default = "SystemAssigned"
}

variable "identity_ids" {
  type    = list(string)
  default = null
}

variable "priority" {
  default = "Regular"
}

variable "max_bid_price" {
  default = -1
}

variable "eviction_policy" {
  default = null
}

variable "tags" {
  default = {}
}


# Additional resources ################

variable "managed_disks" {
  type = map(object({
    storage_account_type           = string
    disk_size_gb                   = string
    virtual_machine_attachment_lun = number
  }))
  default = {}
}

variable "extensions" {
  type = map(object({
    publisher                  = string
    type                       = string
    auto_upgrade_minor_version = optional(bool, true)
    type_handler_version       = string
    settings                   = optional(string)
    protected_settings         = optional(string)
  }))
  default = {}
}