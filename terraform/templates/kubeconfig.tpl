apiVersion: v1
kind: Config
clusters:
- name: spinnaker
  cluster:
    server: ${server}
    certificate-authority-data: ${certificate_authority}
users:
- name: admin
contexts:
- name: spinnaker
  context:
    cluster: spinnaker
    user: admin
current-context: spinnaker