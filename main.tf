locals {
  hosts = concat(var.master_host, var.worker_host)
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
      "rm -rf /root/worker.sh"
    ]
  }

  depends_on = [
    null_resource.bootstrap_master
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
