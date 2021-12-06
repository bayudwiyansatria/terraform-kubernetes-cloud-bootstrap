output "kube_config" {
  sensitive   = true
  description = "Kube Config"
  value       = data.template_file.kube_config.rendered
}

output "cluster_name" {
  sensitive   = false
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "cluster_endpoint" {
  sensitive   = false
  description = "Endpoint"
  value       = local.cluster_endpoint
}

#-----------------------------------------------------------------------------------------------------------------------
# Authentication
#-----------------------------------------------------------------------------------------------------------------------
output "cluster_ca_certificate" {
  sensitive   = true
  description = "Kubernetes Cluster CA Certificate"
  value       = local.cluster_ca_data
}

output "cluster_client_certificate" {
  sensitive   = true
  description = "Kubernetes Cluster Client Certificate"
  value       = local.cluster_client_data
}

output "cluster_client_key" {
  sensitive   = true
  description = "Kubernetes Cluster Client Private Key"
  value       = local.cluster_client_key
}