output "kube_config" {
  sensitive   = true
  description = "Kube Config"
  value       = null_resource.kube_config.triggers.config_file
  depends_on  = [
    null_resource.kube_config
  ]
}

output "cluster_name" {
  sensitive   = false
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "cluster_endpoint" {
  sensitive   = false
  description = "Endpoint"
  value       = null_resource.kube_config.triggers.host
  depends_on  = [
    null_resource.kube_config
  ]
}

#-----------------------------------------------------------------------------------------------------------------------
# Authentication
#-----------------------------------------------------------------------------------------------------------------------
output "cluster_ca_certificate" {
  sensitive   = true
  description = "Kubernetes Cluster CA Certificate"
  value       = null_resource.kube_config.triggers.cluster_ca_certificate
  depends_on  = [
    null_resource.kube_config
  ]
}

output "cluster_client_certificate" {
  sensitive   = true
  description = "Kubernetes Cluster Client Certificate"
  value       = null_resource.kube_config.triggers.client_crt_data
  depends_on  = [
    null_resource.kube_config
  ]
}

output "cluster_client_key" {
  sensitive   = true
  description = "Kubernetes Cluster Client Private Key"
  value       = null_resource.kube_config.triggers.client_key
  depends_on  = [
    null_resource.kube_config
  ]
}