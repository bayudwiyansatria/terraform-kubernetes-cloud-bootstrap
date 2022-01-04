#-----------------------------------------------------------------------------------------------------------------------
# Operations
#-----------------------------------------------------------------------------------------------------------------------
resource "local_file" "ssh_private_key" {
  sensitive_content = var.ssh_private_key
  filename          = "${path.module}/secrets/ssh_private_key.pem"
  file_permission   = "0400"
}

resource "null_resource" "kube_config" {
  triggers = {
    config_file            = data.template_file.kube_config.rendered
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_data
    client_crt_data        = local.cluster_client_data
    client_key             = local.cluster_client_key
  }
  depends_on = [
    data.template_file.kube_config
  ]
}

resource "null_resource" "get_kube_config" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${local_file.ssh_private_key.filename} root@${var.master_host[0]}:/etc/kubernetes/admin.conf ${path.module}/secrets/admin.conf"
  }

  triggers = {
    run = timestamp()
  }

  depends_on = [
    local_file.ssh_private_key,
    null_resource.bootstrap_master
  ]
}

resource "null_resource" "print_join_token" {
  triggers = {
    run = timestamp()
  }

  connection {
    host        = var.master_host[0]
    type        = "ssh"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "kubeadm token create --print-join-command > /tmp/kubeadm_join"
    ]
  }

  depends_on = [
    null_resource.bootstrap_master
  ]
}

#-----------------------------------------------------------------------------------------------------------------------
# Container
#-----------------------------------------------------------------------------------------------------------------------
module "docker" {
  count           = var.docker_enabled ? 1 : 0
  source          = "bayudwiyansatria/bootstrap/docker"
  version         = "1.0.0"
  server_ips      = local.hosts
  ssh_private_key = var.ssh_private_key
}

#-----------------------------------------------------------------------------------------------------------------------
# Kubernetes
#-----------------------------------------------------------------------------------------------------------------------
resource "null_resource" "bootstrap_cluster" {
  count = length(var.worker_host)
  connection {
    host        = var.master_host[0]
    type        = "ssh"
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = local_file.ssh_private_key.filename
    destination = "/tmp/ssh_private_key"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /tmp/ssh_private_key"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/ssh_private_key /tmp/kubeadm_join root@${var.worker_host[count.index]}:/tmp/kubeadm_join"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/ssh_private_key"
    ]
  }

  depends_on = [
    local_file.ssh_private_key,
    null_resource.print_join_token
  ]
}

resource "null_resource" "bootstrap" {
  count = length(local.hosts)
  connection {
    host        = local.hosts[count.index]
    type        = "ssh"
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "file" {
    source      = "${path.module}/files/kubeadm.conf"
    destination = "/root/10-kubeadm.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "KUBERNETES_VERSION=${var.kubernetes_version} FEATURE_GATES=${var.feature_gates} bash /root/bootstrap.sh"
    ]
  }

  depends_on = [
    module.docker
  ]
}

resource "null_resource" "bootstrap_master" {
  count = length(var.master_host)
  connection {
    host        = var.master_host[count.index]
    type        = "ssh"
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = "${path.module}/scripts/master.sh"
    destination = "/root/master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "FEATURE_GATES=${var.feature_gates} POD_NETWORK_CIDR=${var.pod_network_cidr} bash /root/master.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /root/bootstrap.sh",
      "rm -rf /root/master.sh"
    ]
  }

  depends_on = [
    null_resource.bootstrap
  ]
}

resource "null_resource" "bootstrap_worker" {
  count = length(var.worker_host)
  connection {
    host        = var.worker_host[count.index]
    type        = "ssh"
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    source      = "${path.module}/scripts/worker.sh"
    destination = "/root/worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "KUBERNETES_VERSION=${var.kubernetes_version} bash /root/worker.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /root/bootstrap.sh",
      "rm -rf /root/worker.sh",
      "rm -rf /tmp/kubeadm_join"
    ]
  }

  depends_on = [
    null_resource.bootstrap_cluster
  ]
}

#--------------------------------------------------
# CNI
#--------------------------------------------------

resource "null_resource" "calico" {
  connection {
    host        = var.master_host[0]
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://docs.projectcalico.org/archive/v3.15/manifests/calico.yaml"
    ]
  }

  depends_on = [
    null_resource.bootstrap_master
  ]
}
