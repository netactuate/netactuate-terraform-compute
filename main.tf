terraform {
  required_providers {
    netactuate = {
      source  = "netactuate/netactuate"
      version = ">= 0.1.0"
    }
  }
  required_version = ">= 1.0"
}

provider "netactuate" {
  api_key = var.api_key
}

resource "netactuate_sshkey" "deploy" {
  count = var.ssh_key_id == null ? 1 : 0
  name  = "${var.hostname_prefix}-deploy-key"
  key   = file(var.ssh_public_key_path)
}

locals {
  # Build a flat map of location + index for each VM
  vm_instances = merge([
    for loc in var.locations : {
      for i in range(var.vm_count_per_location) :
      "${var.hostname_prefix}-${loc}-${i + 1}" => {
        location = loc
        index    = i + 1
      }
    }
  ]...)
}

resource "netactuate_server" "node" {
  for_each = local.vm_instances

  hostname                   = "${each.key}.${var.domain}"
  plan                       = var.plan
  location                   = each.value.location
  image                      = var.os_image
  ssh_key_id                 = var.ssh_key_id != null ? var.ssh_key_id : netactuate_sshkey.deploy[0].id
  package_billing            = "usage"
  package_billing_contract_id = var.contract_id
}
