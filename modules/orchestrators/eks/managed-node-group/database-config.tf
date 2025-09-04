# Kubernetes Secret for database credentials
resource "kubernetes_secret" "database_credentials" {
  count = length(var.database_environment_vars) > 0 ? 1 : 0

  metadata {
    name      = "${var.project_name}-database-secret"
    namespace = "default"
    labels = {
      app  = var.project_name
      env  = var.environment
      type = "database"
    }
  }

  data = {
    for key, value in var.database_environment_vars : key => value
  }

  type = "Opaque"
}

# Kubernetes ConfigMap for non-sensitive database configuration
resource "kubernetes_config_map" "database_config" {
  count = length(var.database_environment_vars) > 0 ? 1 : 0

  metadata {
    name      = "${var.project_name}-database-config"
    namespace = "default"
    labels = {
      app  = var.project_name
      env  = var.environment
      type = "database"
    }
  }

  data = {
    NODE_ENV = var.environment
    APP_NAME = var.project_name
  }
}

# Sample Kubernetes Deployment for backend service
resource "kubernetes_manifest" "backend_deployment_sample" {
  count = length(var.database_environment_vars) > 0 ? 1 : 0

  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "${var.project_name}-backend-${var.environment}"
      namespace = "default"
      labels = {
        app = "${var.project_name}-backend"
        env = var.environment
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "${var.project_name}-backend"
          env = var.environment
        }
      }
      template = {
        metadata = {
          labels = {
            app = "${var.project_name}-backend"
            env = var.environment
          }
        }
        spec = {
          containers = [
            {
              name  = "backend"
              image = "nginx:latest" # This should be replaced with your ECR image
              ports = [
                {
                  containerPort = 8080
                }
              ]
              envFrom = [
                {
                  secretRef = {
                    name = kubernetes_secret.database_credentials[0].metadata[0].name
                  }
                },
                {
                  configMapRef = {
                    name = kubernetes_config_map.database_config[0].metadata[0].name
                  }
                }
              ]
              readinessProbe = {
                httpGet = {
                  path = "/health"
                  port = 8080
                }
                initialDelaySeconds = 30
                periodSeconds       = 10
              }
              livenessProbe = {
                httpGet = {
                  path = "/health"
                  port = 8080
                }
                initialDelaySeconds = 60
                periodSeconds       = 30
              }
            }
          ]
        }
      }
    }
  }

  depends_on = [
    kubernetes_secret.database_credentials,
    kubernetes_config_map.database_config
  ]
}