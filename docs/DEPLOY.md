# Deployment Guide

## Target Environment
This solution has been tested on a self-hosted k3s cluster hosted on Hetzner Cloud instances.  It assumes there is already a running Kubernetes cluster and a valid local kubeconfig YAML file with admin access to it.  The Terraform module also requires access to Scalr.io remote backend, Hetzner Cloud API, GitHub access through PAT and a webhook URL for notifications.

Refer to [Terraform `.tfvars` sample](../terraform/terraform.tfvars.sample) for required credentials and secrets.

Additional generic parameters are available in [locals](../terraform/main.tf)

For production-like setup an Ingress or Gateway controller and a Cert Manager is required.  Since Ingress API is deprecated, Gateway API usage is strongly recommended.
External DNS Operator can be used to automate management of DNS records for Ingress and HTTPRoute resources.

Cert Manager and a Let's Encrypt Issuer/ClusterIssuer can be added to the Kubernetes cluster to provision TLS certificates for ingress instances dynamically.

To collect metrics from Argo CD and PostgreSQL components Prometheus Operator is required, otherwise [lines L222-236](../terraform/postgresql.tf#L222-L236) need to be commented out.

## Prerequisites
The following CLI tools are required for usage of this repository:
* `git`
* `tofu` or `terraform`
* `kubectl`
* `helm`

Capacity of 4 vCPU and 8 Gib of memory is required for healthy rollout and lifecycle of the stack.

## Setup and Deploy
The entire stack is managed with [Terraform module](../terraform)

```
git clone git@github.com:getnickai/take-home-devops-task-m.git
cd take-home-devops-task-m/terraform

tofu init
tofu apply -target helm_release.postgres_operator -target helm_release.argo_cd -target helm_release.argo_cd_image_updater
[confirm the apply]
tofu apply
[confirm the apply]
```

The first successful apply should setup Zalando Postgres Operator and Argo CD with Image Updater.
The second and final apply provisions a PostgreSQL cluster with a pooler, configures users, databases and backups.  This apply will also deploy 2 isolated instances of `devops-task-api` as Argo CD Applications - staging and production environments.

> [!NOTE]
> To avoid the extra Helm Charts Terraform apply step, Kubernetes CRDs defined as `kubernetes_manifest` resources in the Terraform module need to be encapsulated in Helm Charts.

Applications use [Helm Chart](../k8s/charts/devops-api) in this repo as source and watches for changes on `HEAD`.  PostgreSQL credentials are preloaded into `devops-task-api` container environments from Kubernetes secrets auto-provisioned by Postgres Operator.  Argo CD Image Updater is used to update environments: an ImageUpdater will watch for tags matching the allowed patterns and updater Argo CD Applications directly in Kubernetes.

Each commit or update of pull request targetted to the `main` brach of this repo containing changes in [`src/`](../src) directory, [`Dockerfile`](../Dockerfile) or [`package.json`](../package.json) will trigger a GitHub Actions Workflow that will build and test the `devops-task-api`, pack and push a docker image to GitHub Container Registry with tags after the commit SHA and `latest`.
Staging environment is configured to follow updates of the `latest` tag by image digest.
Each semantic git tag on this repo will trigger another Workflow that will just build and push a docker image with `v<git-tag>` tag presuming that git tags are created manually and knowing that this will trigger a production release.
Production environment is configured to follow semantic versioned tags prioritizing the latest built image.

## Teardown
```
tofu destroy
```

## Step 5: Verify

- [ ] App responds at /health with {"status": "ok"}
- [ ] PostgreSQL cluster shows N healthy replicas
- [ ] Connection pooler is running and app routes through it
- [ ] Backup schedule is active (show how to check)
- [ ] GitOps sync status is healthy (show how to check)
