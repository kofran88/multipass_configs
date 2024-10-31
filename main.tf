provider "multipass" {}

terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4.1"
    }
  }
}

variable "wsversion" {
  description = "Workshop version"
  type        = string
  default     = "5.70"
}

variable "user_data_tpl" {
  description = "user data template filename in templates/"
  type        = string
  default     = "userdata.yaml"
}

variable "architecture" {
  description = "Architecture of the instance (amd64 or arm64)"
  type        = string
  default     = "amd64"
}

variable "instance_password" {
  default = "multipass"
}

variable "hostname" {
  description = "Hostname for Multipass instance"
  type        = string
  default     = "kubed"
}

locals {
  template_vars = {
    instance_name     = var.hostname
    wsversion         = var.wsversion
    architecture      = var.architecture
    instance_password = var.instance_password
  }
}

resource "local_file" "user_data" {
  filename = "ubuntu-cloudinit.yml"
  content  = templatefile(var.user_data_tpl, merge(local.template_vars))
}

data "multipass_instance" "ubuntu" {
  name = var.hostname
  depends_on = [
    multipass_instance.ubuntu
  ]
}

resource "multipass_instance" "ubuntu" {
  name           = var.hostname
  cpus           = 4
  memory         = "8G"
  disk           = "32G"
  image          = "22.04"
  cloudinit_file = local_file.user_data.filename
}
