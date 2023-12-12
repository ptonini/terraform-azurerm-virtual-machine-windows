module "before" {
  source        = "ptonini/vm-requirements/azurerm"
  version       = "~> 1.0.0"
  name          = var.name
  host_count    = var.host_count
  subnet_id     = var.subnet_id
  rg            = var.rg
  public_ip     = var.public_ip
  network_rules = var.network_rules
}


resource "azurerm_windows_virtual_machine" "this" {
  count                 = var.host_count
  name                  = "${var.name}${format("%04.0f", count.index + 1)}"
  computer_name         = "${var.name}${format("%04.0f", count.index + 1)}"
  location              = var.rg.location
  resource_group_name   = var.rg.name
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = var.admin_username
  availability_set_id   = module.before.availability_set_id
  network_interface_ids = [module.before.network_interface_ids[count.index]]
  source_image_id       = var.source_image_id
  max_bid_price         = var.max_bid_price
  priority              = var.priority
  eviction_policy       = var.eviction_policy

  os_disk {
    disk_size_gb         = var.os_disk_size_gb
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account.primary_blob_endpoint
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_reference[*]
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  dynamic "plan" {
    for_each = var.plan[*]
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["business_unit"],
      tags["environment"],
      tags["product"],
      tags["subscription_type"]
    ]
  }
}

module "after" {
  source             = "ptonini/vm-dependencies/azurerm"
  version            = "~> 1.0.0"
  count              = var.host_count
  rg                 = var.rg
  virtual_machine_id = azurerm_windows_virtual_machine.this[count.index].id
  extensions         = { for k, v in var.extensions : "${k}-${count.index}" => v }
  managed_disks      = { for k, v in var.managed_disks : "${k}-${count.index}" => v }
  depends_on = [
    azurerm_windows_virtual_machine.this
  ]
}