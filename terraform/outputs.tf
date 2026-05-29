output "worker_ip" {
  description = "IP address of the worker VM"
  value       = libvirt_domain.worker.network_interface[0].addresses[0]
}

output "db_ip" {
  description = "IP address of the db VM"
  value       = libvirt_domain.db.network_interface[0].addresses[0]
}

output "worker_ssh" {
  description = "SSH command to connect to worker as ansible user"
  value       = "ssh ansible@${libvirt_domain.worker.network_interface[0].addresses[0]}"
}

output "db_ssh" {
  description = "SSH command to connect to db as ansible user"
  value       = "ssh ansible@${libvirt_domain.db.network_interface[0].addresses[0]}"
}

output "ansible_inventory_path" {
  description = "Path to the generated Ansible inventory"
  value       = abspath("${path.module}/../ansible/inventory.yml")
}