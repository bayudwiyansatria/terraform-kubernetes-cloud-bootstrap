apiVersion: v1
kind: Config
preferences: {}
current-context: ${CLUSTER_NAME}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CLUSTER_CA_DATA}
    server: ${CLUSTER_ENDPOINT}
contexts:
- name: ${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: ${CLUSTER_USERNAME}
users:
- name: ${CLUSTER_USERNAME}
  user:
    client-certificate-data: ${CLIENT_CRT_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
    