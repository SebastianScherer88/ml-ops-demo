resource "helm_release" "cert-manager-controller" {
  count = var.helm_cert_manager.install ? 1 : 0

  name             = var.helm_cert_manager.chart_release_name
  repository       = var.helm_cert_manager.repository
  chart            = var.helm_cert_manager.chart_name
  version          = var.helm_cert_manager.chart_version
  namespace        = var.helm_cert_manager.namespace
  create_namespace = true

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.id
  }

  set {
    name  = "image.tag"
    value = var.helm_cert_manager.template_values["image.tag"]
  }

  set {
    name  = "installCRDs"
    value = var.helm_cert_manager.template_values["installCRDs"]
  }

  set {
    name  = "serviceAccount.name"
    value = var.helm_cert_manager.template_values["serviceAccount.name"]
  }

  depends_on = [
    aws_eks_node_group.private-nodes,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}

resource "helm_release" "aws-load-balancer-controller" {
  count = var.helm_aws_load_balancer_controller.install ? 1 : 0

  name             = var.helm_aws_load_balancer_controller.chart_release_name
  repository       = var.helm_aws_load_balancer_controller.repository
  chart            = var.helm_aws_load_balancer_controller.chart_name
  version          = var.helm_aws_load_balancer_controller.chart_version # careful when pinning chart and image version: https://github.com/aws/eks-charts/issues/1058
  namespace        = var.helm_aws_load_balancer_controller.namespace
  create_namespace = var.helm_aws_load_balancer_controller.create_namespace

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.id
  }

  set {
    name  = "image.tag"
    value = var.helm_aws_load_balancer_controller.template_values["image.tag"]
  }

  set {
    name  = "serviceAccount.name"
    value = var.helm_aws_load_balancer_controller.template_values["serviceAccount.name"]
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  set {
    name  = "enableCertManager"
    value = var.helm_aws_load_balancer_controller.template_values["enableCertManager"]
  }

  depends_on = [
    helm_release.cert-manager-controller
  ]
}

resource "helm_release" "metrics-server" {
  count = var.helm_metrics_server.install ? 1 : 0

  name             = var.helm_metrics_server.chart_release_name
  repository       = var.helm_metrics_server.repository
  chart            = var.helm_metrics_server.chart_name
  version          = var.helm_metrics_server.chart_version
  namespace        = var.helm_metrics_server.namespace
  create_namespace = var.helm_metrics_server.create_namespace

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.id
  }

  set {
    name  = "image.tag"
    value = var.helm_metrics_server.template_values["image.tag"]
  }

  set {
    name  = "serviceAccount.name"
    value = var.helm_metrics_server.template_values["serviceAccount.name"]
  }

  depends_on = [
    helm_release.cert-manager-controller
  ]
}

resource "random_password" "grafana_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "helm_release" "observability" {
  count = var.helm_observability.install ? 1 : 0

  name             = var.helm_observability.chart_release_name
  repository       = var.helm_observability.repository
  chart            = var.helm_observability.chart_name
  version          = var.helm_observability.chart_version
  namespace        = var.helm_observability.namespace
  create_namespace = var.helm_observability.create_namespace

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.id
  }

  set {
    name  = "prometheus.serviceAccount.name"
    value = var.helm_observability.template_values["prometheus.serviceAccount.name"]
  }

  set {
    name  = "prometheusOperator.serviceAccount.name"
    value = var.helm_observability.template_values["prometheusOperator.serviceAccount.name"]
  }

  set {
    name  = "grafana.serviceAccount.name"
    value = var.helm_observability.template_values["grafana.serviceAccount.name"]
  }

  set {
    name  = "grafana.adminPassword"
    value = random_password.grafana_admin_password.result
  }

  set {
    name  = "kube-state-metrics.namespaceOverride"
    value = var.helm_observability.template_values["kube-state-metrics.namespaceOverride"]
  }

  depends_on = [
    helm_release.cert-manager-controller
  ]
}