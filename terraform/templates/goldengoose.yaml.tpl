apiVersion: v1
kind: Namespace
metadata:
  name: goldengoose
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: docker-dippynark
  namespace: goldengoose
secrets:
- name: docker-dippynark
---
apiVersion: v1
kind: Secret
metadata:
  name: docker-dippynark
  namespace: goldengoose
  annotations:
    build.knative.dev/docker-0: https://index.docker.io/v1/
type: kubernetes.io/basic-auth
data:
  username: ZGlwcHluYXJr
  password: ${docker_dippynark_password}