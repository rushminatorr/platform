resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller"
    }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin"
    }

    # api_group has to be empty because of a bug:
    # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/204
    subject {
        api_group = ""
        kind      = "ServiceAccount"
        name      = "tiller"
        namespace = "kube-system"
    }
}

# resource "helm_release" "iofog" {
#     name       = "iofog"
#     repository = "https://eclipse-iofog.github.io/helm"
#     chart      = "iofog"

#     values = [<<EOF
# namespace: dev
# connector: 
#   image: gcr.io/focal-freedom-236620/connector:develop
# controller:
#   image: gcr.io/focal-freedom-236620/controller:develop
# EOF
#     ]

#     depends_on = ["kubernetes_cluster_role_binding.tiller"]
# }

# resource "helm_release" "iofog-k8s" {
#     name       = "iofog-k8s"
#     repository = "https://eclipse-iofog.github.io/helm"
#     chart      = "iofog-k8s"

#     values = [<<EOF
# namespace: dev
# kubelet: 
#   image: gcr.io/focal-freedom-236620/kubelet:dev-latest
# operator:
#   image: gcr.io/focal-freedom-236620/operator:dev-latest
# schedule:
#   image: gcr.io/focal-freedom-236620/scheduler:dev-latest
# EOF
#     ]

#     depends_on = ["helm_release.iofog"]
# }