# Part 5: Deployment Instructions -- Template

Your `DEPLOY.md` should enable a colleague to deploy the entire stack to a clean Kubernetes cluster by following your instructions step by step.

Use the structure below as a starting point. You may add sections but should not remove any.

---

```markdown
# Deployment Guide

## Target Environment
<!-- State which K8s platform you chose (Kind, Minikube, k3d, EKS, GKE, AKS) and why -->

## Prerequisites
<!-- List all required CLI tools with minimum versions -->
<!-- List required access/credentials (cloud accounts, container registries, etc.) -->
<!-- State minimum resource requirements (CPU, memory, disk) -->

## Step 1: Cluster Setup
<!-- How to create or access the cluster -->
<!-- Any cluster-level configuration (RBAC, namespaces, storage classes) -->

## Step 2: Install Infrastructure Components
<!-- Install order matters. Cover: -->
<!-- - Ingress controller -->
<!-- - Cert-manager (if applicable) -->
<!-- - GitOps tool (ArgoCD/Flux) -->
<!-- - PostgreSQL operator -->
<!-- - Secret management tooling -->

## Step 3: Configure Secrets
<!-- How to create required secrets (DB credentials, registry access, etc.) -->
<!-- How these integrate with your secret management approach -->

## Step 4: Deploy the Stack
<!-- GitOps-based deployment steps -->
<!-- Or manual steps if GitOps bootstraps itself -->

## Step 5: Verify

- [ ] App responds at /health with {"status": "ok"}
- [ ] PostgreSQL cluster shows N healthy replicas
- [ ] Connection pooler is running and app routes through it
- [ ] Backup schedule is active (show how to check)
- [ ] GitOps sync status is healthy (show how to check)

## Troubleshooting
<!-- Common failure modes and how to diagnose/fix them -->
<!-- At minimum: pod not starting, DB connection refused, GitOps sync failed -->

## Teardown
<!-- Clean removal in correct order -->
<!-- Confirm no orphaned resources remain -->
```

---

## What We're Evaluating

- Could a peer engineer follow these instructions from scratch and end up with a working stack?
- Are prerequisites complete (nothing assumed)?
- Are steps in the correct dependency order?
- Does verification actually confirm the system works end-to-end?
- Is teardown included and complete?

## The Solution

# Deployment Guide

## Target Environment
This solution has been tested on a self-hosted k3s cluster hosted on Hetzner Cloud instances.

## Prerequisites
<!-- List all required CLI tools with minimum versions -->
git
tofu
kubectl
helm

<!-- List required access/credentials (cloud accounts, container registries, etc.) -->
scalr_token
hcloud_token
kube_config
github_pat
webhook_url
<!-- State minimum resource requirements (CPU, memory, disk) -->

## Step 1: Cluster Setup
<!-- How to create or access the cluster -->
Access to cluster is provided through a valid local kubeconfig YAML file.
<!-- Any cluster-level configuration (RBAC, namespaces, storage classes) -->

## Step 2: Install Infrastructure Components
<!-- Install order matters. Cover: -->
<!-- - Ingress controller -->
<!-- - Cert-manager (if applicable) -->
<!-- - GitOps tool (ArgoCD/Flux) -->
<!-- - PostgreSQL operator -->
<!-- - Secret management tooling -->
```
tofu init
tofu apply
```

## Step 3: Configure Secrets
<!-- How to create required secrets (DB credentials, registry access, etc.) -->
<!-- How these integrate with your secret management approach -->

## Step 4: Deploy the Stack
<!-- GitOps-based deployment steps -->
<!-- Or manual steps if GitOps bootstraps itself -->

## Step 5: Verify

- [ ] App responds at /health with {"status": "ok"}
- [ ] PostgreSQL cluster shows N healthy replicas
- [ ] Connection pooler is running and app routes through it
- [ ] Backup schedule is active (show how to check)
- [ ] GitOps sync status is healthy (show how to check)

## Troubleshooting
<!-- Common failure modes and how to diagnose/fix them -->
<!-- At minimum: pod not starting, DB connection refused, GitOps sync failed -->

## Teardown
<!-- Clean removal in correct order -->
<!-- Confirm no orphaned resources remain -->
```
tofu destroy
```
