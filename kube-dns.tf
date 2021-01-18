# this is taken from https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/d8e78504c51b194ce30e736f7a3a4240b9dbcd9d/dns.tf
# but modified to set upstreamResolvers instead of stubDomains

/******************************************
  Delete default kube-dns configmap
 *****************************************/
resource "null_resource" "delete_default_kube_dns_configmap" {
  provisioner "local-exec" {
    command = format(
      "%s/scripts/kubectl_wrapper.sh https://%s %s %s %s/scripts/delete-default-resource.sh kube-system configmap kube-dns",
      path.module,
      local.cluster_endpoint,
      data.google_client_config.default.access_token,
      local.cluster_ca_certificate,
      path.module,
    )
  }

  depends_on = [
    data.google_client_config.default,
    google_container_cluster.kubeflow_cluster,
  ]
}

/******************************************
  Create kube-dns confimap
 *****************************************/
resource "kubernetes_config_map" "kube-dns" {
  metadata {
    name      = "kube-dns"
    namespace = "kube-system"
  }

  data = {
    upstreamNameservers = <<EOF
jsonencode(var.upstream_nameservers)
EOF
  }

  depends_on = [
    null_resource.delete_default_kube_dns_configmap,
    google_container_cluster.kubeflow_cluster,
  ]
}

