# Part 3: PostgreSQL Operator -- Additional Context

## Why This Matters

Running a bare PostgreSQL container in Kubernetes (as seen in the current `docker-compose.yml`) is fine for local development but fails in production:

- **No replication** -- a single pod failure means downtime
- **No automated backups** -- data loss on volume corruption or accidental deletion
- **No failover** -- manual intervention required to recover
- **No connection pooling** -- PostgreSQL's per-connection process model doesn't scale well under load

Kubernetes operators solve this by encoding operational knowledge (backup scheduling, failover logic, replica management) into a controller that watches Custom Resources.

## Acceptable Operators

You may use any PostgreSQL operator. Here are three well-established options:

- **CloudNativePG** -- https://cloudnative-pg.io/
  - CNCF Sandbox project, actively maintained
  - Native Kubernetes integration (no external dependencies like Patroni)
  - Built-in Barman for backups, PgBouncer pooler CR

- **Zalando Postgres Operator** -- https://github.com/zalando/postgres-operator
  - Battle-tested at Zalando's scale
  - Uses Patroni for HA and Spilo images
  - Connection pooling via built-in PgBouncer sidecar

- **CrunchyData PGO (v5)** -- https://github.com/CrunchyData/postgres-operator
  - Enterprise-grade, pgBackRest for backups
  - Built-in monitoring with pgMonitor
  - PgBouncer integration

## Key Considerations

### Application Connection
The API application uses the `DATABASE_URL` environment variable (see `src/index.js`). Your final configuration must set this to point at the **connection pooler** endpoint, not directly at the PostgreSQL primary.

### Backup Storage
If you don't have access to a cloud object store (S3, GCS, Azure Blob), you can:
- Use MinIO as a local S3-compatible store within the cluster
- Use PVC-based backups (less ideal but acceptable for this exercise)
- Document what you would change for a real cloud deployment

### What We're Evaluating

- Can you justify your operator choice with trade-offs?
- Is the cluster CR complete and functional (instances, storage, bootstrap)?
- Are backups scheduled with a sensible retention policy?
- Is connection pooling configured and wired to the application?
- Does your DR runbook contain actionable steps, not just theory?
