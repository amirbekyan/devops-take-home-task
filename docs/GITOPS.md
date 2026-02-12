# Part 4: GitOps Migration -- Additional Context

## Why This Matters

The current `/k8s` directory contains raw manifests applied manually with `kubectl apply`. This approach doesn't scale:

- No audit trail of what's deployed vs. what's in Git
- Manual applies are error-prone and hard to reproduce
- No environment separation (staging vs. production)
- No automated drift detection or self-healing
- Secrets are committed in plaintext (the ConfigMap contains credentials)

GitOps solves this by making Git the single source of truth for cluster state. A controller in the cluster watches the repo and reconciles actual state with desired state.

## Acceptable Tools

- **ArgoCD** -- https://argo-cd.readthedocs.io/
  - Declarative Application CRs, web UI for visibility
  - ApplicationSet for templating across environments
  - Supports Helm, Kustomize, Jsonnet, and plain YAML

- **Flux CD** -- https://fluxcd.io/
  - GitOps Toolkit architecture (modular controllers)
  - GitRepository + Kustomization CRs
  - Native Helm and Kustomize support
  - Image automation controllers

You may use another tool if you can justify the choice.

## Directory Structure

You'll need to reorganize the manifests. There is no single correct structure, but here are two common patterns:

### Kustomize-based
```
gitops/
  base/
    deployment.yaml
    service.yaml
    ingress.yaml
    kustomization.yaml
  overlays/
    staging/
      kustomization.yaml
      patches/
    production/
      kustomization.yaml
      patches/
```

### Helm-based
```
charts/
  devops-api/
    Chart.yaml
    values.yaml
    values-staging.yaml
    values-production.yaml
    templates/
      deployment.yaml
      service.yaml
      ingress.yaml
```

These are examples, not requirements. Choose a structure that makes sense and explain your rationale.

## Secret Management

Committing plaintext secrets to Git is not acceptable. You must address this. Options include:

- **Sealed Secrets** (Bitnami) -- encrypts secrets client-side, decrypted only in-cluster
- **SOPS** (Mozilla) -- encrypts values in YAML/JSON files using KMS, PGP, or age keys
- **External Secrets Operator** -- syncs secrets from external stores (AWS Secrets Manager, Vault, etc.)
- **Vault** (HashiCorp) -- full secret management platform with K8s integration

At minimum, document your approach. Ideally, include the configuration.

## What We're Evaluating

- Is the directory structure clean, logical, and maintainable?
- Do the GitOps CRs (Application, Kustomization, etc.) actually work?
- Are at least 2 environments configured with meaningful differences?
- Is there a sync policy (auto vs. manual) and is the choice justified?
- Is secret management addressed (not just acknowledged)?

## The Solution

## Tooling Choice
ArgoCD has secured it's standing as a de facto industry standard tool with it's simplicity.  At the same time it has numerous features, supports plugins and is easily scalable.  Helm Charts are used to template Kubernetes resources of the application - this will enabled usage of the same source both in live and development environments.

## Environments & Promotion
There are two live environments: `production` and `staging` which are isolated in different Kubernetes namespaces and use different databases.

