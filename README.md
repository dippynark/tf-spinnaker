# Cloud Native Demos

This project is intended to house a range of 'full stack' demos of Cloud Native applications & technologies running on Kubernetes. The project should house the configuration to spin up the demos quickly and document the process to do so.

Current Demos:
- Spinnaker pipelines triggered by GitHub webhooks

Ideas for future demos:
- Istio visualizations for a distributed applications

## Private GKE cluster

To deploy Spinnaker into a [private GKE cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters) uncomment the `private_ip_google_access` field in `terraform/network.tf` and uncomment the `private_cluster_config` section in `terraform/gke.tf`

## Quickstart

```
# edit state bucket name in Makefile
# edit terraform/terraform.tfvars.example and rename to terraform/terraform.tfvars
make init
make plan
make apply
```

## nginx-ingress

```
# point gate and deck domains at nginx-ingress LB IP
echo $(kubectl get service nginx-ingress-controller -n nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# apply ingress.yaml
kubectl apply -f terraform/ingress.yaml
```

## Spin

[Install spin](https://www.spinnaker.io/guides/spin/cli/)

```
mkdir -p ~/.spin
cat <<EOF > ~/.spin/config
auth:
  enabled: true
  oauth2:
    authUrl: https://github.com/login/oauth/authorize # OAuth2 provider auth url
    tokenUrl: https://github.com/login/oauth/access_token # OAuth2 provider token url
    clientId: xxxxxxxxxx # OAuth2 client id
    clientSecret: xxxxxxxxx # OAuth2 client secret
    scopes: # Scopes requested for the token
    - scope1
    #- scope2
EOF
```

## Cleanup

```
make destroy
```

## Plan

Build image with knative and push to DockerHub
Pipeline to deploy goldengoose to local cluster
Collect metrics from goldengoose
Canary analysis
Istio support
Metrics and logging visualisation
