# Spinnaker

This repository contains resources for provisioning Spinnaker on GCP using Terraform.

## Quickstart

```
# edit state bucket name in Makefile
# edit terraform.tfvars.example and rename to terraform.tfvars
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

## Cleanup

```
make destroy
```