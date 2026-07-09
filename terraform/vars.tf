variable "location" {
  type    = string
  default = "northcentralus"  # swedencentral bloqueada
}

variable "prefix" {
  type    = string
  default = "casopractico2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}


variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/cp2_vm.pub"
}

# Ruta a la clave SSH PRIVADA que usará Ansible para conectarse a la VM
variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/cp2_vm"
}