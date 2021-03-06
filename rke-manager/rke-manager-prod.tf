terraform {
  required_providers {
    vsphere = {
      #version = "~> 1.23.0"
      version = "2.0.1"
    }
  }

  backend "gcs" {
    bucket  = "yru-prod-terraform-state-files"
    prefix = "yru-openedx-rke-manager-prod"
  }   
}

provider "vsphere" {
  user           = var.vcenter_username
  password       = var.vcenter_password
  vsphere_server = var.vcenter_host

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

locals {
  gateway      = "10.10.5.1"
  vm_network   = "vm-network-105"
  vm_datastore = "HCI-Datastore"
  vm_poolname  = "OpenEdx-Prod"
  vm_dc_name   = "HX-YRU-Datacenter"
  num_cpus    = 1 #Core
  memory_size = 2048 #MB
  disk_size   = 70 #GB
  netmask     = 24
  test_provisioner = "provision-manager.bash"
  admin_user    = "yruadmin"
  guest_id      = "ubuntu64Guest"
  dns_list      = ["10.10.2.5" , "10.10.2.6"]
  lib_name      = ""

  lib_item_name = ""
  vcenter_template_or_vm_name = "OPENEDX-RKE-MNGR-TEMPLATE-UBT16-1"
}

module "test-vm-01" {
  source                = "git::https://github.com/its-software-services-devops/tf-module-vsphere-vm.git//modules?ref=1.0.1"
  vm_host               = "yru-prod-rke-manager-01"
  vcenter_vm_name       = "yru-prod-rke-manager-01"
  vcenter_vapp_name     = ""
  vm_gateway            = local.gateway
  vm_guest_id           = local.guest_id
  vm_dns_list           = local.dns_list
  num_cpus              = local.num_cpus
  memory_size           = local.memory_size
  disk_size             = local.disk_size
  vcenter_datastore     = local.vm_datastore
  vcenter_pool_name     = local.vm_poolname
  vcenter_dc_name       = local.vm_dc_name
  vcenter_library_name        = local.lib_name
  vcenter_library_item_name   = local.lib_item_name
  provisioner_script          = local.test_provisioner
  vcenter_template_or_vm_name = local.vcenter_template_or_vm_name
  admin_password        = var.admin_password
  admin_user            = local.admin_user
  ssh-pub-key           = var.vm_public_key
  ssh_ip_address        = "10.10.5.50"
  disk_thin_provisioned = true
  wait_for_guest_ip_timeout = 0
  wait_for_guest_net_timeout = 0
  #script_entry_dir = "/tmp"

  network_configs       = [{index = 1, use_static_mac = false, mac_address = "", vm_ip = "10.10.5.50", vcenter_network_name = local.vm_network, vm_netmask = 24}]
  external_disks        = []
}
