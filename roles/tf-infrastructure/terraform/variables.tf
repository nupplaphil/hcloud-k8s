// DO NOT EDIT - ANSIBLE replace the variables

variable "hcloud_token" {
  type        = string
  description = "Hetzner Cloud API Token - Replaced by Ansible Playbook on run"
}

variable "datacenter" {
  type        = string
  description = "Datacenter Location - Replaced by Ansible Playbook on run"
}

variable "master_servertype" {
  type        = string
  description = "Master Server Type - Replaced by Ansible Playbook on run"
}

variable "worker1_servertype" {
  type        = string
  description = "Worker1 Server Type - Replaced by Ansible Playbook on run"
}

variable "worker2_servertype" {
  type        = string
  description = "Worker2 Server Type - Replaced by Ansible Playbook on run"
}

variable "worker3_servertype" {
  type        = string
  description = "Worker3 Server Type - Replaced by Ansible Playbook on run"
}

variable "worker4_servertype" {
  type        = string
  description = "Worker4 Server Type - Replaced by Ansible Playbook on run"
}

variable "worker1_count" {
  type        = number
  description = "Worker1 count - Replaced by Ansible Playbook on run"
}

variable "worker2_count" {
  type        = number
  description = "Worker2 count - Replaced by Ansible Playbook on run"
}

variable "worker3_count" {
  type        = number
  description = "Worker3 count - Replaced by Ansible Playbook on run"
}

variable "worker4_count" {
  type        = number
  description = "Worker4 count - Replaced by Ansible Playbook on run"
}

variable "domain" {
  type        = string
  description = "Top Level Domain - Replaced by Ansible Playbook on run"
}

variable "lb_type" {
  type        = string
  description = "Loadbalancer Type - Replaced by Ansible Playbook on run"
}

variable "lb_datacenter" {
  type        = string
  description = "Loadbalancer datacenter - Replaced by Ansible Playbook on run"
}

variable "lb_enabled" {
  type        = bool
  description = "Enable Loadbalancer - Replaced by Ansible Playbook on run"
}
