#!/usr/bin/env bash

set -eu

eval "$(cat /tmp/kubeadm_join)"
systemctl enable docker kubelet
