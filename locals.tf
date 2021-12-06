locals {
  private_key_filename = "/tmp/ssh_private_key"
  hosts                = concat(var.master_host, var.worker_host)
}

locals {
  config   = yamldecode(data.local_file.kube_config.content)
  clusters = local.config.clusters[0]
  users    = local.config.users[0]

  cluster_name        = local.clusters.name
  cluster_ca_data     = local.clusters.cluster.certificate-authority-data
  cluster_endpoint    = local.clusters.cluster.server
  cluster_client_data = local.users.user.client-certificate-data
  cluster_client_key  = local.users.user.client-key-data

  depends_on = [
    data.local_file.kube_config
  ]
}