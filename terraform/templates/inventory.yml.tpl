---
all:
  children:
    workers:
      hosts:
        worker:
          ansible_host: ${worker_ip}
          ansible_user: ansible
          ansible_ssh_private_key_file: "~/.ssh/id_ed25519"
    db_servers:
      hosts:
        db:
          ansible_host: ${db_ip}
          ansible_user: ansible
          ansible_ssh_private_key_file: "~/.ssh/id_ed25519"
