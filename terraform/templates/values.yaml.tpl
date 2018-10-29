halyard:
  spinnakerVersion: ${spinnaker_version}
  image:
    repository: gcr.io/spinnaker-marketplace/halyard
    tag: ${spinnaker_version}
  # Provide a config map with Hal commands that will be run the core config (storage)
  # The config map should contain a script in the config.sh key
  additionalScripts:
    enabled: true
    configMapName: additional-halyard-config
    configMapKey: config.sh
    # If you'd rather do an inline script, set create to true and put the content in the data dict like you would a configmap
    create: true
    data:
      config.sh: |
        hal --daemon-endpoint $DAEMON_ENDPOINT config security authn oauth2 edit \
          --client-id ${spinnaker_oauth_client_id} \
          --client-secret ${spinnaker_oauth_client_secret} \
          --provider ${spinnaker_oauth_provider} \
          --pre-established-redirect-uri https://${spinnaker_gate_domain}/login
        hal --daemon-endpoint $DAEMON_ENDPOINT config security authn oauth2 enable

        hal --daemon-endpoint $DAEMON_ENDPOINT config security ui edit --override-base-url https://${spinnaker_deck_domain}
        hal --daemon-endpoint $DAEMON_ENDPOINT config security api edit --override-base-url https://${spinnaker_gate_domain} 

        hal --daemon-endpoint $DAEMON_ENDPOINT config features edit --artifacts true
        hal --daemon-endpoint $DAEMON_ENDPOINT config artifact github enable
        hal --daemon-endpoint $DAEMON_ENDPOINT config artifact github account add github-artifact-account

  additionalSecrets:
    create: false
    data: {}
  additionalConfigMaps:
    create: false
    data: {}

# Define which registries and repositories you want available in your
# Spinnaker pipeline definitions
# For more info visit:
#   https://www.spinnaker.io/setup/providers/docker-registry/

# Configure your Docker registries here
dockerRegistries:
- name: dockerhub
  address: index.docker.io
  repositories:
    - dippynark/goldengoose
# - name: gcr
#   address: https://gcr.io
#   username: _json_key
#   password: '<INSERT YOUR SERVICE ACCOUNT JSON HERE>'
#   email: 1234@5678.com

# If you don't want to put your passwords into a values file
# you can use a pre-created secret instead of putting passwords
# (specify secret name in below `dockerRegistryAccountSecret`)
# per account above with data in the format:
# <name>: <password>

# dockerRegistryAccountSecret: myregistry-secrets

kubeConfig:
  # Use this when you want to register arbitrary clusters with Spinnaker
  # Upload your ~/kube/.config to a secret
  enabled: false
  secretName: my-kubeconfig
  secretKey: config
  # List of contexts from the kubeconfig to make available to Spinnaker
  contexts:
  - default
  deploymentContext: default

# Change this if youd like to expose Spinnaker outside the cluster
ingress:
  enabled: false
  # host: spinnaker.example.org
  # annotations:
    # ingress.kubernetes.io/ssl-redirect: 'true'
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  # tls:
  #  - secretName: -tls
  #    hosts:
  #      - domain.com

ingressGate:
  enabled: false
  # host: gate.spinnaker.example.org
  # annotations:
    # ingress.kubernetes.io/ssl-redirect: 'true'
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  # tls:
  #  - secretName: -tls
  #    hosts:
  #      - domain.com

# spinnakerFeatureFlags is a list of Spinnaker feature flags to enable
# Ref: https://www.spinnaker.io/reference/halyard/commands/#hal-config-features-edit
# spinnakerFeatureFlags:
#   - artifacts
#   - pipeline-templates
spinnakerFeatureFlags:
  - artifacts
  - jobs

# Node labels for pod assignment
# Ref: https://kubernetes.io/docs/user-guide/node-selection/
# nodeSelector to provide to each of the Spinnaker components
nodeSelector: {}

# Redis password to use for the in-cluster redis service
# Redis is not exposed publically
redis:
  password: password
  nodeSelector: {}
  cluster:
    enabled: false
# Uncomment if you don't want to create a PVC for redis
#  master:
#    persistence:
#      enabled: false

# Minio access/secret keys for the in-cluster S3 usage
# Minio is not exposed publically
minio:
  enabled: false
  imageTag: RELEASE.2018-06-09T02-18-09Z
  serviceType: ClusterIP
  accessKey: spinnakeradmin
  secretKey: spinnakeradmin
  bucket: "spinnaker"
  nodeSelector: {}
# Uncomment if you don't want to create a PVC for minio
#  persistence:
#    enabled: false

# Google Cloud Storage
gcs:
  enabled: true
  project: ${gcp_project}
  bucket: "${gcs_storage_bucket_name}"
  jsonKey: '${gcs_service_account_json}'

# AWS Simple Storage Service
s3:
  enabled: false
  bucket: "<S3-BUCKET-NAME>"
  # rootFolder: "front50"
  # region: "us-east-1"
  # endpoint: ""
  # accessKey: ""
  # secretKey: ""

# Azure Storage Account
azs:
  enabled: false
#   storageAccountName: ""
#   accessKey: ""
#   containerName: "spinnaker"

rbac:
  # Specifies whether RBAC resources should be created
  create: true

serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true
  # The name of the ServiceAccounts to use.
  # If left blank it is auto-generated from the fullname of the release
  halyardName:
  spinnakerName: