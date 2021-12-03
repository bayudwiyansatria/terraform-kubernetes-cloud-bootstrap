#-----------------------------------------------------------------------------------------------------------------------
# Container
#-----------------------------------------------------------------------------------------------------------------------
variable "docker_enabled" {
  type        = bool
  description = "Enable Docker"
  default     = true
}

#-----------------------------------------------------------------------------------------------------------------------
# Kubernetes
#-----------------------------------------------------------------------------------------------------------------------

variable "master_host" {
  type        = list(string)
  description = "Kubernetes Master Node IP"
}

variable "worker_host" {
  type        = list(string)
  description = "Kubernetes Worker Node IP"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH Private Key"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.20.0"
}

variable "feature_gates" {
  type        = string
  description = "Add Feature Gates e.g. 'DynamicKubeletConfig=true'"
  default     = ""
}

variable "pod_network_cidr" {
  type        = string
  description = "Pod Network CIDR. Currently using Calico https://docs.projectcalico.org/about/about-calico"
  default     = "192.168.0.0/16"
}