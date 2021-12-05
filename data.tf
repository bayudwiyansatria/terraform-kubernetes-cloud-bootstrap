data "local_file" "kube_config" {
  filename   = "${path.module}/secrets/admin.conf"
  depends_on = [
    null_resource.get_kube_config
  ]
}

data "template_file" "kube_config" {
  template = file("${path.module}/templates/kubeconfig.yaml.tpl")
  vars     = {
    CLUSTER_NAME     = local.cluster_name
    CLUSTER_CA_DATA  = local.cluster_ca_data
    CLUSTER_ENDPOINT = local.cluster_endpoint
    CLUSTER_USERNAME = local.cluster_name
    CLIENT_CRT_DATA  = local.cluster_client_data
    CLIENT_KEY_DATA  = local.cluster_client_key
  }
}
