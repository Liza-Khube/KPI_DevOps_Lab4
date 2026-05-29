terraform {
   required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "mywebapp" {
  name = "mywebapp"
  type = "dir"
  path = "/var/lib/libvirt/images/mywebapp"
}

resource "libvirt_volume" "ubuntu_image" {
  name   = "ubuntu-24.04.qcow2"
  pool   = libvirt_pool.mywebapp.name
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_network" "mywebapp_network" {
  name      = "mywebapp_network"
  mode      = "nat"
  domain    = "mywebapp.local"
  addresses = [var.network_cidr]
}

resource "libvirt_cloudinit_disk" "worker" {
  name      = "mywebapp-worker-cloud-init.iso"
  pool      = libvirt_pool.mywebapp.name
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    ssh_public_key = var.ssh_public_key
  })
}

resource "libvirt_cloudinit_disk" "db" {
  name      = "mywebapp-db-cloud-init.iso"
  pool      = libvirt_pool.mywebapp.name
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    ssh_public_key = var.ssh_public_key
  })
}

resource "libvirt_volume" "worker_disk" {
  name           = "worker.qcow2"
  pool           = libvirt_pool.mywebapp.name
  base_volume_id = libvirt_volume.ubuntu_image.id
  size           = var.disk_size_bytes
}

resource "libvirt_domain" "worker" {
  name   = "worker-vm"
  memory = var.worker_memory_mb
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.worker.id

  network_interface {
    network_id     = libvirt_network.mywebapp_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

resource "libvirt_volume" "db_disk" {
  name           = "db.qcow2"
  pool           = libvirt_pool.mywebapp.name
  base_volume_id = libvirt_volume.ubuntu_image.id
  size           = var.disk_size_bytes
}

resource "libvirt_domain" "db" {
  name   = "db-vm"
  memory = var.db_memory_mb
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.db.id

  network_interface {
    network_id     = libvirt_network.mywebapp_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    worker_ip = libvirt_domain.worker.network_interface[0].addresses[0]
    db_ip     = libvirt_domain.db.network_interface[0].addresses[0]
  })
  filename        = "${path.module}/../ansible/inventory.yml"
  file_permission = "0644"
}

resource "local_file" "ansible_group_vars_all" {
  content = templatefile("${path.module}/templates/group_vars_all.yml.tpl", {
    worker_ip   = libvirt_domain.worker.network_interface[0].addresses[0]
    db_ip       = libvirt_domain.db.network_interface[0].addresses[0]
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    app_port    = var.app_port
  })
  filename        = "${path.module}/../ansible/group_vars/all.yml"
  file_permission = "0644"
}
