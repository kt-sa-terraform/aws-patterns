resource "kubernetes_namespace" "default_namespace" {
  count = length(var.namespaces)
  metadata {
    name = var.namespaces[count.index]
  }
}
