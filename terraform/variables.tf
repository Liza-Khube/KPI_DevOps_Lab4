variable "ssh_public_key" {
  description = "SSH public key for ansible user (paste content of your ~/.ssh/id_rsa.pub or id_ed25519.pub)"
  type        = string
}

variable "network_cidr" {
  description = "CIDR of internal NAT network"
  type        = string
  default     = "192.168.100.0/24"
}

variable "worker_memory_mb" {
  description = "RAM for worker VM in MB"
  type        = number
  default     = 2048
}

variable "db_memory_mb" {
  description = "RAM for db VM in MB"
  type        = number
  default     = 2048
}

variable "disk_size_bytes" {
  description = "Disk size for each VM (bytes). Default 10 GB"
  type        = number
  default     = 10737418240
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "mywebapp_db"
}

variable "db_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
  default     = "mySecretPasswd"
}

variable "app_port" {
  description = "Port the web application listens on"
  type        = number
  default     = 8080
}
