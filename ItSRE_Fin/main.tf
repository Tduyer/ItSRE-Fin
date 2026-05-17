terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "namespace_name" {
  type    = string
  default = "sre-ecommerce-prod"
}

resource "kubernetes_namespace" "sre_prod" {
  metadata {
    name = var.namespace_name
    labels = {
      environment = "production"
      managed-by  = "terraform"
    }
  }
}

# SRE Best Practice: Ограничение ресурсов (Resource Quota) для защиты кластера от перегрузки
resource "kubernetes_resource_quota" "compute_quota" {
  metadata {
    name      = "compute-resources-quota"
    namespace = kubernetes_namespace.sre_prod.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = "2"
      "requests.memory" = "4Gi"
      "limits.cpu"      = "4"
      "limits.memory"   = "8Gi"
      "pods"            = "10"
    }
  }
}