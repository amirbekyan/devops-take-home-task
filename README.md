# DevOps Take-Home Task

## Overview

This repo contains a simple Node.js API with PostgreSQL. Your task spans five parts: fix the broken Docker setup and CI pipeline, fix and review Kubernetes manifests, deploy PostgreSQL using a Kubernetes operator with production-grade features, migrate to a GitOps workflow, and write deployment instructions for a clean cluster.

**Time estimate:** 4-6 hours

---

## Part 1: Fix the Broken Environment (Hands-on)

The app should start with `docker-compose up` and the CI pipeline should pass. Currently, neither works.

### Your Tasks

1. Fork this repository
2. Fix the issues so the app runs locally with `docker-compose up`
3. Fix the GitHub Actions workflow so it builds successfully
4. Submit a PR with your fixes

### Expected Behavior (When Fixed)

- `docker-compose up` starts the app and database
- App responds at `http://localhost:3000/health` with `{"status": "ok"}`
- App connects to PostgreSQL successfully
- GitHub Actions workflow builds and pushes the image

### Deliverable

- A PR with all your fixes
- In the PR description, include a brief incident report:
  - What was broken?
  - How did you diagnose each issue?
  - What did you fix?

---

## Part 2: Kubernetes Review & Fix (Hands-on + Written)

The manifests in the `/k8s` folder have issues that would cause problems in production.

### Your Tasks

1. Review all manifests in `/k8s`
2. Fix every issue you find (commit the corrected manifests)
3. Create a file called `K8S_REVIEW.md` in your PR with:
   - What problems did you find?
   - How did you fix each one?
   - What's missing that you'd add for production readiness?

---

## Part 3: PostgreSQL Operator (Hands-on)

The current setup uses a bare PostgreSQL container with no persistence guarantees, no replication, and no backup strategy. Deploy PostgreSQL using a Kubernetes operator with production-grade features.

### Requirements

Choose a PostgreSQL operator (e.g., CloudNativePG, Zalando Postgres Operator, CrunchyData PGO) and configure:

1. **High Availability** -- Primary-replica read replication with at least 1 replica
2. **Automated Backups** -- Scheduled backups (e.g., daily) with a retention policy. Storage destination is your choice (S3-compatible, PVC, etc.)
3. **Disaster Recovery** -- Document and configure your DR strategy. How do you restore from a backup? How does failover work?
4. **Connection Pooling** -- PgBouncer, PgPool-II, or the operator's built-in pooling. The API application must connect through the pooler, not directly to PostgreSQL

### Deliverable

- Operator installation manifests or instructions (Helm values, kustomization, etc.)
- PostgreSQL cluster Custom Resource manifests
- Connection pooling configuration
- A file `PG_OPERATOR.md` explaining:
  - Which operator you chose and why
  - Architecture overview (text-based diagram is fine)
  - Backup schedule and retention policy
  - DR runbook: step-by-step restore procedure
  - How connection pooling is configured and how the app connects

See `docs/PART3_PG_OPERATOR.md` for additional context and hints.

---

## Part 4: Migrate to GitOps (Hands-on)

The raw manifests in `/k8s` are applied manually with `kubectl`. Migrate to a GitOps workflow.

### Requirements

Choose a GitOps tool (e.g., ArgoCD, Flux CD) and:

1. **Organize manifests** using Helm, Kustomize, or plain manifests in a GitOps-friendly structure
2. **Create GitOps configuration** -- Application CRs for ArgoCD, Kustomization/GitRepository for Flux, etc.
3. **Environment separation** -- Show how you handle at least 2 environments (e.g., staging + production) with different configurations
4. **Sync policy** -- Configure automated or manual sync with pruning
5. **Secret management** -- Address how secrets are handled in your GitOps workflow (Sealed Secrets, SOPS, External Secrets, etc.)

### Deliverable

- Restructured manifest directory
- GitOps tool configuration manifests
- A file `GITOPS.md` explaining:
  - Which tool you chose and why
  - Directory structure rationale
  - How deployments are triggered
  - How environment promotion works
  - How secrets are managed

See `docs/PART4_GITOPS.md` for additional context.

---

## Part 5: Deployment Instructions (Written)

Write a `DEPLOY.md` that enables someone to deploy the entire stack (app + PostgreSQL operator + GitOps) to a clean Kubernetes cluster.

### Requirements

Choose your target platform (local: Kind, Minikube, k3d; or cloud: EKS, GKE, AKS) and include:

1. Prerequisites (tools, versions, access requirements)
2. Step-by-step instructions from zero to running stack
3. Verification steps (how to confirm everything works)
4. Troubleshooting for common issues
5. Teardown instructions

See `docs/PART5_DEPLOYMENT.md` for the expected template.

---

## Evaluation Criteria

| Area | What we're looking for |
|------|------------------------|
| Debugging | Methodical approach, finds root causes (Parts 1 & 2) |
| Code quality | Clean fixes, well-organized manifests |
| Communication | Clear incident report, architecture documentation |
| K8s knowledge | Identifies issues, production hardening (Part 2) |
| Database operations | Operator choice rationale, HA/DR/backup config (Part 3) |
| GitOps maturity | Tool choice, env separation, secret management (Part 4) |
| Operational readiness | Deployment docs are usable by a peer (Part 5) |
| Production mindset | Monitoring, security, reliability throughout |

---

## Questions?

If something is unclear, document your assumptions and proceed. We value seeing how you think through ambiguity.
