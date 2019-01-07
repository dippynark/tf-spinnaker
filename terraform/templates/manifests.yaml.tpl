apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller-cluster-admin
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
---
apiVersion: v1
kind: Namespace
metadata:
  name: spinnaker
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${gcp_account}-cluster-admin
subjects:
- kind: User
  name: ${gcp_account}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
---
apiVersion: v1
kind: LimitRange
metadata:
  name: limits
  namespace: spinnaker
spec:
  limits:
  - defaultRequest:
      memory: 1Gi
      cpu: 500m
    type: Container 
---
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
  annotations:
    #seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default'
    #seccomp.security.alpha.kubernetes.io/defaultProfileNames: 'docker/default'
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    #apparmor.security.beta.kubernetes.io/defaultProfileNames: 'runtime/default'
spec:
  hostPID: false
  hostIPC: false
  hostNetwork: false
  privileged: false
  allowPrivilegeEscalation: true  
  readOnlyRootFilesystem: false
  allowedCapabilities:
  - '*'
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
    # knative build
    - hostPath
  fsGroup:
    rule: RunAsAny  
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp:restricted
rules:
- apiGroups: ['extensions']
  resources: ['podsecuritypolicies']
  verbs:     ['use']
  resourceNames:
  - restricted
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: psp:restricted
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp:restricted
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io