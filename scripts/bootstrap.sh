#!/usr/bin/env bash

set -eu
KUBERNETES_VERSION=${KUBERNETES_VERSION:-}

waitForPackage() {
  while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    echo "Waiting for other software managers to finish..."
    sleep 1
  done
}

apt-get -qq update
apt-get -qq install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  git \
  jq \
  bash-completion \
  nfs-common

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo "
Package: kubelet
Pin: version ${KUBERNETES_VERSION}-*
Pin-Priority: 1000
" > /etc/apt/preferences.d/kubelet

echo "
Package: kubeadm
Pin: version ${KUBERNETES_VERSION}-*
Pin-Priority: 1000
" > /etc/apt/preferences.d/kubeadm

waitForPackage

apt-get -qq update
apt-get -qq install -y kubelet kubeadm

mv -v /root/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet

source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
