# Лабораторна робота №4. IaC. Terraform. Ansible. Setup Guide

### Для виконання роботи використовувалось:

- Середовище WSL2 (Windows 11)
- Terraform v1.15.4
- Ansible v2.16.3

### Попередні вимоги:

- Встановлені Terraform та Ansible
- Налаштований гіпервізор KVM/QEMU та провайдер libvirt
- Згенерований SSH-ключ за адресою `~/.ssh/id_ed25519` (публічний ключ використовується для доступу):

  `ssh-keygen -t ed25519`

### Налаштування змінних Terraform

```
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Відредагувати `terraform.tfvars` :

- `ssh_public_key` (обов'язково)
- `network_cidr`
- `db_password` (обов'язково)

### Розгорнути інфраструктуру (Terraform)

В папці terraform ініціалізувати провайдери та створити віртуальні машини::

`terraform init && terraform apply -auto-approve`

### Налаштування конфігурації (Ansible)

Terraform автоматично згенерує актуальний файл `inventory` з новими IP-адресами машин. Перейти до директорії `ansible` та запустити головний плейбук:

```
cd ../ansible
ansible-playbook playbook.yml
```

Ansible автоматично встановить усі необхідні залежності, налаштує PostgreSQL, Node.js застосунок, Nginx як reverse proxy та правила фаєрвола (UFW).
