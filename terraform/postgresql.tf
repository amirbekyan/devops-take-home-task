resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "helm_release" "postgres_operator" {
  name       = "postgres-operator"
  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator"
  chart      = "postgres-operator"
  namespace  = kubernetes_namespace.postgres.id
  version    = "1.15.1"

  values = [templatefile("${path.module}/src/helm/helm-values-postgres-operator.yml", {
    operator_version         = "v1.15.1"
    spilo_version            = "17:4.0-p3"
    major_version_upgrade    = "manual"
    min_version              = "13"
    target_version           = "17"
    backup_version           = "v1.15.1"
    pooler_version           = "master-32"
    cluster_domain           = local.cluster_domain
    cross_ns_secret          = true
    owner_ref                = true
    pod_env_cm               = kubernetes_config_map.postgres_operator_pod_env.metadata.0.name
    pod_env_sec              = kubernetes_secret.postgres_operator_pod_sec.metadata.0.name
    secret_name_tpl          = "{username}.{cluster}.pg-credentials"
    physical_backup_region   = local.region
    physical_backup_endpoint = local.s3_endpoint
    physical_backup_bucket   = minio_s3_bucket.postgresql.bucket
    logical_backup_provider  = "s3"
    logical_backup_endpoint  = local.s3_endpoint
    logical_backup_bucket    = minio_s3_bucket.postgresql.bucket
    logical_backup_schedule  = "30 00 * * *"
    logical_backup_retention = "15 days"
    s3_access_key            = var.hcloud_s3_access_key
    s3_secret_key            = var.hcloud_s3_secret_key
    s3_sse                   = ""
  })]
}

resource "kubernetes_secret" "postgres_operator_pod_sec" {
  metadata {
    name      = "postgres-pod-sec-overrides"
    namespace = kubernetes_namespace.postgres.id
  }
  data = {
    AWS_ACCESS_KEY_ID     = var.hcloud_s3_access_key
    AWS_SECRET_ACCESS_KEY = var.hcloud_s3_secret_key
  }
}

resource "kubernetes_config_map" "postgres_operator_pod_env" {
  metadata {
    name      = "postgres-pod-env-overrides"
    namespace = kubernetes_namespace.postgres.id
  }
  data = {
    "USE_WALG_BACKUP"         = "false"
    "USE_WALG_RESTORE"        = "false"
    "CLONE_USE_WALG_RESTORE"  = "false"
    "BACKUP_SCHEDULE"         = "20 00 * * *"
    "BACKUP_NUM_TO_RETAIN"    = "15"
    "AWS_S3_FORCE_PATH_STYLE" = "true"
  }
}

resource "kubernetes_manifest" "devops_task_postgresql" {
  manifest = {
    apiVersion = "acid.zalan.do/v1"
    kind       = "postgresql"
    metadata = {
      name      = "postgresql-devops-task"
      namespace = kubernetes_namespace.postgres.id
    }
    spec = {
      enableLogicalBackup    = true
      logicalBackupSchedule  = "30 00 * * *"
      logicalBackupRetention = "15 days"
      maintenanceWindows = [
        "02:00-05:00" # UTC
      ]
      numberOfInstances = 2
      users = {
        for env, param in local.environments :
        "${param.namespace}.${param.db_user}" => [
          "superuser",
          "createdb"
        ]
      }
      databases = {
        for env, param in local.environments :
        param.database => "${param.namespace}.${param.db_user}"
      }
      enableMasterLoadBalancer        = false
      enableReplicaLoadBalancer       = false
      enableConnectionPooler          = true
      enableReplicaConnectionPooler   = true
      enableMasterPoolerLoadBalancer  = false
      enableReplicaPoolerLoadBalancer = false
      postgresql = {
        version = "17"
        parameters = {
          max_connections  = "150"
          wal_level        = "logical"
          log_statement    = "all"
          shared_buffers   = "32MB"
          listen_addresses = "*"
        }
      }
      connectionPooler = {
        numberOfInstances = 2
        mode              = "transaction"
        schema            = "pooler"
        user              = "pooler"
        maxDBConnections  = 60
        resources = {
          requests = {
            cpu    = "250m"
            memory = "100Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "200Mi"
          }
        }
      }
      patroni = {
        initdb = {
          encoding       = "UTF8"
          locale         = "en_US.UTF-8"
          data-checksums = true
        }
        pg_hba = [
          "local   all         postgres           trust",
          "host    all         all      0.0.0.0/0 md5",
          "hostssl all         all      0.0.0.0/0 md5",
          "host    all         postgres ::1/128   md5",
          "local   replication standby            trust",
          "host    replication standby  0.0.0.0/0 md5",
          "hostssl replication standby  0.0.0.0/0 md5",
        ]
      }
      teamId = local.env
      volume = {
        size         = "20Gi"
        storageClass = "hcloud-volumes"
      }
      sidecars = [
        {
          name  = "exporter"
          image = "quay.io/prometheuscommunity/postgres-exporter:latest"
          ports = [
            {
              name          = "exporter"
              containerPort = 9187
              protocol      = "TCP"
            }
          ]
          env = [
            {
              name  = "DATA_SOURCE_URI"
              value = "localhost:5432/postgres"
            },
            {
              name  = "DATA_SOURCE_USER"
              value = "$(POSTGRES_USER)"
            },
            {
              name  = "DATA_SOURCE_PASS"
              value = "$(POSTGRES_PASSWORD)"
            }
          ]
        }
      ]
      resources = {
        requests = {
          cpu    = "50m"
          memory = "100Mi"
        }
        limits = {
          cpu    = "250m"
          memory = "500Mi"
        }
      }
    }
  }
}

resource "kubernetes_service" "devops_task_postgresql_metrics" {
  metadata {
    name      = "postgresql-metrics-devops-task"
    namespace = kubernetes_namespace.postgres.id
    labels = {
      app = "postgresql-devops-task"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "exporter"
      port        = 9187
      target_port = 9187
    }
    selector = {
      application = "spilo"
      cluster     = "postgresql-devops-task"
    }
  }
}

resource "helm_release" "devops_task_postgresql_svcmon" {
  name       = "postgresql-svcmon-devops-task"
  repository = "https://raw.githubusercontent.com/amirbekyan/helm-charts/gh-pages/"
  chart      = "servicemon"
  namespace  = kubernetes_namespace.postgres.id
  version    = "0.1.0"

  values = [
    templatefile("${path.module}/src/helm/helm-values-servicemon.yml", {
      servicemonitors = indent(2, yamlencode([
        {
          name      = "postgresql-devops-task"
          namespace = kubernetes_namespace.postgres.id
          labels = {
            release = "prometheus"
          }
          selector = {
            app = "postgresql-devops-task"
          }
          endpoints = [
            {
              port = "exporter"
            }
          ]
        }
      ]))
    })
  ]
}
