apiVersion: v1
kind: Namespace
metadata:
  name: spinnaker
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: spinnaker
  namespace: spinnaker
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: client-cluster-admin
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
      cpu: 200m
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
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: spinnaker
rules:
- apiGroups: [""]
  resources: ["namespaces", "configmaps", "events", "replicationcontrollers", "serviceaccounts", "pods/logs"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "services", "secrets"]
  verbs: ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["list", "get"]
- apiGroups: ["apps"]
  resources: ["controllerrevisions", "statefulsets"]
  verbs: ["list"]
- apiGroups: ["extensions", "apps"]
  resources: ["deployments", "replicasets", "ingresses"]
  verbs: ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
# These permissions are necessary for halyard to operate. We use this role also to deploy Spinnaker itself.
- apiGroups: [""]
  resources: ["services/proxy", "pods/portforward"]
  verbs: ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: spinnaker
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole 
  name: spinnaker
subjects:
- namespace: spinnaker
  kind: ServiceAccount
  name: spinnaker
---
apiVersion: v1
kind: Secret
metadata:
  name: gcs-service-account
  namespace: spinnaker
data:
  gcs-service-account.json: ${gcs_service_account_json}
---
apiVersion: v1
kind: Service
metadata:
  name: halyard
  namespace: spinnaker
  labels:
    app: halyard
spec:
  ports:
  - port: 9000
    name: deck
  - port: 8084
    name: gate
  clusterIP: None
  selector:
    app: halyard
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: halyard
  namespace: spinnaker
spec:
  selector:
    matchLabels:
      app: halyard
  serviceName: halyard
  replicas: 1
  template:
    metadata:
      labels:
        app: halyard
    spec:
      serviceAccountName: spinnaker
      securityContext:
        fsGroup: 1000
      containers:
      - name: halyard
        image: gcr.io/spinnaker-marketplace/halyard:stable
        env:
        - name: GCP_PROJECT
          value: "${gcp_project}"
        - name: GCS_STORAGE_BUCKET_NAME
          value: "${gcs_storage_bucket_name}"
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /home/spinnaker/.gcp/gcs-service-account.json
        - name: KUBECONFIG
          value: /home/spinnaker/.hal/kubeconfig
        - name: CLIENT_ID
          value: "${spinnaker_oauth_client_id}"
        - name: CLIENT_SECRET
          value: "${spinnaker_oauth_client_secret}"
        - name: PROVIDER
          value: "${spinnaker_oauth_provider}"
        - name: DECK_DOMAIN
          value: "${spinnaker_deck_domain}"
        - name: GATE_DOMAIN
          value: "${spinnaker_gate_domain}"
        - name: VERSION 
          value: "${spinnaker_version}"
        lifecycle:
          postStart:
            exec:
              command:
              - /bin/bash
              - -c
              - |
                # generate kubeconfig
                KUBERNETES_CLUSTER_IP=$(KUBECONFIG="" kubectl get service kubernetes -n default -o jsonpath='{.spec.clusterIP}')                
                kubectl config set-cluster spinnaker \
                  --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
                  --embed-certs=true \
                  --server=https://$${KUBERNETES_CLUSTER_IP}
                kubectl config set-credentials spinnaker \
                  --token $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
                kubectl config set-context spinnaker \
                  --cluster=spinnaker \
                  --user=spinnaker        
                kubectl config use-context spinnaker

                # halyard                
                # https://github.com/spinnaker/spinnaker/issues/3357
                # https://github.com/spinnaker/halyard/blob/master/halyard-cli/src/main/java/com/netflix/spinnaker/halyard/cli/services/v1/Daemon.java#L80
                until curl http://localhost:8064/health | grep -i "up"
                do
                  sleep 1
                done
                hal config provider kubernetes enable
                hal config provider kubernetes account add default \
                  --provider-version v2 \
                  --context $(kubectl config current-context) \
                  --kubeconfig-file "$${KUBECONFIG}"
                hal config features edit --artifacts true
                hal config deploy edit --type distributed --account-name default
                hal config storage gcs edit --project "$${GCP_PROJECT}" \
                  --bucket "$${GCS_STORAGE_BUCKET_NAME}" \
                  --json-path "$${GOOGLE_APPLICATION_CREDENTIALS}"
                hal config storage edit --type gcs
                hal config version edit --version "$${VERSION}"

                hal config security authn oauth2 edit \
                --client-id $${CLIENT_ID} \
                --client-secret $${CLIENT_SECRET} \
                --provider $${PROVIDER} \
                --pre-established-redirect-uri https://$${GATE_DOMAIN}/login
                hal config security authn oauth2 enable
                hal config security ui edit --override-base-url https://$${DECK_DOMAIN}
                hal config security api edit --override-base-url https://$${GATE_DOMAIN}

                hal deploy apply
        ports:
        - containerPort: 9000
          name: deck
        - containerPort: 8084
          name: gate
        volumeMounts:
        - name: halyard
          mountPath: /home/spinnaker/.hal
        - name: gcs-service-account
          mountPath: /home/spinnaker/.gcp
      volumes:
      - name: gcs-service-account
        secret:
          secretName: gcs-service-account
  volumeClaimTemplates:
  - metadata:
      name: halyard
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: standard
      resources:
        requests:
          storage: 1Gi